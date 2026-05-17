import SwiftUI

struct PlayingView: View {
    var gameManager: GameManager
    
    var body: some View {
        let question = gameManager.questions[gameManager.currentQuestionIndex]
        
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                question.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                Text("Question \(gameManager.currentQuestionIndex + 1) / 10")
                    .font(.headline)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .padding(.top, 40)
            }
            
            VStack(spacing: 15) {
                Text("Which color name best describes the background?")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                ForEach(question.options) { option in
                    Button(action: {
                        gameManager.selectAnswer(option)
                    }) {
                        Text(option.name)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                }
            }
            .id(gameManager.currentQuestionIndex)
            .padding()
            .background(Color(UIColor.systemBackground))
        }
    }
}