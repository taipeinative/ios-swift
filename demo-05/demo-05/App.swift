import SwiftUI

@main
struct Demo05App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State var gameManager = GameManager()
    
    var body: some View {
        Group {
            switch gameManager.gameState {
            case .start:
                StartView(gameManager: gameManager)
            case .playing:
                PlayingView(gameManager: gameManager)
            case .finished:
                ResultView(gameManager: gameManager)
            }
        }
        .animation(.easeInOut, value: gameManager.gameState)
    }
}

#Preview {
    ContentView()
}