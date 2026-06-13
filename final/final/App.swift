import SwiftUI

@main
struct FinalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// Clear programmatic mapping of the application's unique layout scenes
enum AppRoute: Hashable {
    case detail(ReviewTarget)
}

/// Identifies if we are initiating an existing record modification or creating from scratch
enum EditModeDestination: Identifiable {
    case edit(ReviewTarget)
    
    var id: String {
        switch self {
        case .edit(let target): return target.id.uuidString
        }
    }
}

struct ContentView: View {
    @State private var navigationPath = NavigationPath()
    @State private var activeSheetMode: EditModeDestination? = nil
    @State private var targets: [ReviewTarget] = mockTargets
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            MainPage(
                onNavigateToDetail: { target in
                    navigationPath.append(AppRoute.detail(target))
                },
                onPresentCreateNew: {
                    let emptyTarget = ReviewTarget(name: "", type: .location, attributes: [], reviews: [])
                    activeSheetMode = .edit(emptyTarget)
                }
            )
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .detail(let target):
                    DetailPage(
                        target,
                        onNavigateToEdit: { activeSheetMode = .edit(target) },
                        onPopToRoot: { navigationPath.removeLast(navigationPath.count) }
                    )
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .detail(let target):
                    DetailPage(
                        target,
                        onNavigateToEdit: { activeSheetMode = .edit(target) },
                        onPopToRoot: { navigationPath.removeLast(navigationPath.count) }
                    )
                }
            }
            .sheet(item: $activeSheetMode) { mode in
                switch mode {
                case .edit(let targetItem):
                    NavigationStack {
                        EditPage(targetItem) { savedTarget in
                            activeSheetMode = nil
                            if let newTarget = savedTarget {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    navigationPath.append(AppRoute.detail(newTarget))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview("Content View") {
    ContentView()
}

//#Preview("Home") {
//    MainPage()
//}
