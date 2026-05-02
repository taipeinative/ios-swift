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
            
            Tab("主題", systemImage: "list.bullet") {
                CatalogView()
            }

            Tab("搜尋", systemImage: "magnifyingglass", role: .search) {
                SearchView()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    ContentView()
}
