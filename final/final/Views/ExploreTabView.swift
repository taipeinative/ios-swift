import SwiftUI

struct ExploreTabView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "探索功能稍後開放",
                systemImage: "sparkles",
                description: Text("這個分頁先保留空白，之後可以再延伸。")
            )
            .navigationTitle("探索")
        }
    }
}
