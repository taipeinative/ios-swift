import SwiftUI

struct StartView: View {
    var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 30) {
            Text("色彩名稱測驗")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("測試你對色彩名稱的熟悉程度！")
                .multilineTextAlignment(.center)
                .padding()
            
            VStack(spacing: 15) {
                ModeButton(title: "簡單", color: .green) {
                    gameManager.startGame(difficulty: .easy)
                }

                ModeButton(title: "中等", color: .orange) {
                    gameManager.startGame(difficulty: .medium)
                }
                
                ModeButton(title: "困難", color: .red) {
                    gameManager.startGame(difficulty: .hard)
                }
            }
            .padding(.horizontal, 40)
        }
    }
}