import SwiftUI

struct TopicView: View {
    let topic: ArticleCatalog
    @State private var selectedArticle: ArticleLink?

    private var parentName: String {
        ArticleCatalogData.first { $0.id == topic.parentID }?.name ?? ""
    }

    private var articles: [ArticleLink] {
        ArticleCatalogLinks[topic.id] ?? []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Header(title: topic.name, serif: true)
                    .padding(.vertical, 20)
                    .padding(.bottom, 0)
                
                Text("\(parentName)＞\(topic.name)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 6)

                VStack(spacing: 12) {
                    ForEach(articles) { article in
                        Button {
                            selectedArticle = article
                        } label: {
                            HStack {
                                Text(article.title)
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                Image(systemName: "arrow.up.right")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 12)
            }
        }
        .padding(.horizontal, 20)
        .sheet(item: $selectedArticle) { article in
            if let url = URL(string: article.url) {
                NavigationStack {
                    LinkHelper(url: url)
                        .ignoresSafeArea()
                        .navigationTitle(article.title)
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}

#Preview {
    TopicView(topic: ArticleCatalogData[0])
}
