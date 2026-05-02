import SwiftUI

struct CatalogView: View {
    private var levelOneItems: [ArticleCatalog] {
        ArticleCatalogData.filter { $0.level == 1 }
    }

    var body: some View {
        NavigationStack {
            List(levelOneItems) { item in
                NavigationLink(value: item) {
                    Label(item.name, systemImage: item.icon)
                }
            }
            .navigationTitle("主題")
            .navigationDestination(for: ArticleCatalog.self) { item in
                CatalogDetailView(parent: item)
            }
        }
    }
}

struct CatalogDetailView: View {
    let parent: ArticleCatalog

    private var subItems: [ArticleCatalog] {
        ArticleCatalogData.filter { $0.parentID == parent.id }
    }

    var body: some View {
        List(subItems) { item in
            NavigationLink {
                TopicView(topic: item)
            } label: {
                Label(item.name, systemImage: item.icon)
            }
        }
        .navigationTitle(parent.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CatalogView()
}
