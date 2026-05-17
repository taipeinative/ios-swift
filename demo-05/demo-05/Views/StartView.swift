import SwiftUI

struct StartView: View {
    var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Color Name Quiz")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Test your familiarity with CSS color names!")
                .multilineTextAlignment(.center)
                .padding()
            
            VStack(spacing: 15) {
                ModeButton(title: "Easy Mode", color: .green) {
                    gameManager.startGame(difficulty: .easy)
                }

                ModeButton(title: "Medium Mode", color: .orange) {
                    gameManager.startGame(difficulty: .medium)
                }
                
                ModeButton(title: "Hard Mode", color: .red) {
                    gameManager.startGame(difficulty: .hard)
                }
            }
            .padding(.horizontal, 40)
        }
    }
}