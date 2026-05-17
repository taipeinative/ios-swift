import Combine
import SwiftUI
import Observation

enum Difficulty {
    case easy, medium, hard
}

struct Question {
    let backgroundColor: Color
    let targetColor: CustomColor?
    let options: [CustomColor]
    let correctOption: CustomColor
}

@Observable
class GameManager {
    var gameState: GameState = .start
    var currentDifficulty: Difficulty = .easy
    var questions: [Question] = []
    var currentQuestionIndex = 0
    var score = 0
    var results: [(Question, CustomColor)] = []
    
    enum GameState {
        case start
        case playing
        case finished
    }
    
    func startGame(difficulty: Difficulty) {
        self.currentDifficulty = difficulty
        self.questions = generateQuestions(for: difficulty)
        self.currentQuestionIndex = 0
        self.score = 0
        self.results = []
        self.gameState = .playing
    }
    
    func selectAnswer(_ option: CustomColor) {
        let q = questions[currentQuestionIndex]
        let isCorrect = option.id == q.correctOption.id
        if isCorrect { score += 1 }
        results.append((q, option))
        
        if currentQuestionIndex < 9 {
            currentQuestionIndex += 1
        } else {
            gameState = .finished
        }
    }
    
    func restart() {
        gameState = .start
    }
    
    private func generateQuestions(for difficulty: Difficulty) -> [Question] {
        var generated = [Question]()
        for _ in 0..<10 {
            if difficulty == .hard {
                let baseColor = cssColors.randomElement()!
                let r = max(0, min(255, baseColor.r + Double.random(in: -30...30)))
                let g = max(0, min(255, baseColor.g + Double.random(in: -30...30)))
                let b = max(0, min(255, baseColor.b + Double.random(in: -30...30)))
                let bgCSS = CustomColor(name: "bg", r: r, g: g, b: b)
                
                // Sort all colors by distance to this shifted background
                let sorted = cssColors.sorted { $0.distance(to: bgCSS) < $1.distance(to: bgCSS) }
                let correctAnswer = sorted[0]
                
                // Pick 3 from the next 6 closest matching colors to make it hard
                let otherOptions = Array(sorted[1...6].shuffled().prefix(3))
                let options = ([correctAnswer] + otherOptions).shuffled()
                
                generated.append(Question(
                    backgroundColor: bgCSS.color,
                    targetColor: nil,
                    options: options,
                    correctOption: correctAnswer
                ))
            } else {
                let options = generateOptions(for: difficulty)
                let correctAnswer = options.randomElement()!
                
                generated.append(Question(
                    backgroundColor: correctAnswer.color,
                    targetColor: correctAnswer,
                    options: options.shuffled(),
                    correctOption: correctAnswer
                ))
            }
        }
        return generated
    }
    
    private func generateOptions(for difficulty: Difficulty) -> [CustomColor] {
        var pool = cssColors.shuffled()
        var selected = [CustomColor]()
        let target = pool.removeFirst()
        selected.append(target)
        
        while selected.count < 4 {
            let candidate = pool.removeFirst()
            let minDistance = selected.map { candidate.distance(to: $0) }.min() ?? 0
            
            switch difficulty {
            case .easy:
                if minDistance > 20000 { selected.append(candidate) }
            case .medium:
                if minDistance > 5000 && minDistance <= 20000 { selected.append(candidate) }
            case .hard:
                break // Handled directly in generateQuestions
            }
            
            if pool.isEmpty {
                pool = cssColors.shuffled()
                selected.append(pool.removeFirst())
            }
        }
        return selected
    }
}
