import SwiftUI

@main
struct Demo04App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("首頁", systemImage: "house") {
                HomeView()
            }
            
            Tab("目錄", systemImage: "list.bullet") {
                
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    ContentView()
}
