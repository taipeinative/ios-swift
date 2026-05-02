import SwiftUI

struct SearchView: View {
    @State private var query = ""

    private var levelTwoItems: [ArticleCatalog] {
        ArticleCatalogData.filter { $0.level == 2 }
    }

    private var filteredItems: [ArticleCatalog] {
        guard !query.isEmpty else {
            return levelTwoItems
        }

        return levelTwoItems.filter { item in
            item.name.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredItems) { item in
                NavigationLink {
                    TopicView(topic: item)
                } label: {
                    Label(item.name, systemImage: item.icon)
                }
            }
            .navigationTitle("搜尋")
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
        }
    }
}

#Preview {
    SearchView()
}
