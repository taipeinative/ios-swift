import SwiftUI

@main
struct Demo03App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    // Enfore the black color in the light mode
    @Environment(\.colorScheme) private var appColorScheme
    
    // Force the tab to Library (the fourth tab)
    @State private var selectedTab = 3
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: 0) {
                DefaultView(title: "Home")
            }
            Tab("New", systemImage: "square.grid.2x2.fill", value: 1) {
                DefaultView(title: "New")
            }
            Tab("Radio", systemImage: "dot.radiowaves.left.and.right", value: 2) {
                DefaultView(title: "Radio")
            }
            Tab("Library", image: "music.square.stack.fill", value: 3) {
                LibraryView()
                    .tint(nil)
            }
            Tab("Search", systemImage: "magnifyingglass", value: 4, role: .search) {
                DefaultView(title: "Search")
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            NowPlaying(inLightMode: appColorScheme == .light)
        }
        .tint(.pink)
    }
}

#Preview() {
    ContentView()
}
