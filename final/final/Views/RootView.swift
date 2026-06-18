import Observation
import SwiftUI

struct RootView: View {
    @State private var router = AppRouter()
    @AppStorage("isReplacingAppData") private var isReplacingAppData = false

    var body: some View {
        Group {
            if isReplacingAppData {
                DataReplacementProgressView()
            } else {
                TabView(selection: $router.selectedTab) {
                    Tab("首頁", systemImage: "house.fill", value: AppTab.home) {
                        HomeTabView(router: router)
                    }

                    Tab("資料庫", systemImage: "books.vertical.fill", value: AppTab.library) {
                        LibraryTabView()
                    }

                    Tab("洞察", systemImage: "chart.line.uptrend.xyaxis", value: AppTab.explore) {
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
    }
}

private struct DataReplacementProgressView: View {
    var body: some View {
        ZStack {
            AppColors.shared.primarySurface
                .ignoresSafeArea()

            VStack(spacing: 14) {
                ProgressView()
                    .controlSize(.large)

                Text("正在匯入資料")
                    .font(.headline)

                Text("暫時關閉其他分頁，避免在替換資料時讀取到舊的圖片內容。")
                    .font(.footnote)
                    .foregroundStyle(AppColors.shared.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
            }
        }
    }
}
