import Observation
import SwiftUI

struct RootView: View {
    @State private var router = AppRouter()

    var body: some View {
        TabView(selection: $router.selectedTab) {
            Tab("首頁", systemImage: "house.fill", value: AppTab.home) {
                HomeTabView(router: router)
            }

            Tab("資料庫", systemImage: "books.vertical.fill", value: AppTab.library) {
                LibraryTabView()
            }

            Tab("探索", systemImage: "safari", value: AppTab.explore) {
                ExploreTabView()
            }

            Tab("搜尋", systemImage: "magnifyingglass", value: AppTab.search, role: .search) {
                NavigationStack {
                    SearchPageView()
                }
            }
        }
    }
}
