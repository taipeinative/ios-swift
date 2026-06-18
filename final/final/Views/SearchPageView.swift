import SwiftData
import SwiftUI

struct SearchPageView: View {
    @Query(sort: \Target.name, order: .forward) private var targets: [Target]
    @Query(sort: \Review.updated, order: .reverse) private var reviews: [Review]
    @State private var query = ""

    private var normalizedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines).localizedLowercase
    }

    private var matchedTargets: [Target] {
        guard !normalizedQuery.isEmpty else { return [] }
        return targets.filter { $0.searchableText.contains(normalizedQuery) }
    }

    private var matchedReviews: [Review] {
        guard !normalizedQuery.isEmpty else { return [] }
        return reviews.filter { $0.searchableText.contains(normalizedQuery) }
    }

    var body: some View {
        List {
            Section {
                TextField("搜尋文字", text: $query)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

            if normalizedQuery.isEmpty {
                ContentUnavailableView(
                    "開始搜尋",
                    systemImage: "magnifyingglass",
                    description: Text("可搜尋目標名稱、屬性與評論內容。")
                )
            } else {
                Section("目標") {
                    if matchedTargets.isEmpty {
                        Text("沒有符合的目標")
                            .foregroundStyle(AppColors.shared.secondaryText)
                    } else {
                        ForEach(matchedTargets) { target in
                            NavigationLink {
                                TargetDetailView(target: target)
                            } label: {
                                TargetRowView(target: target)
                            }
                        }
                    }
                }

                Section("評論") {
                    if matchedReviews.isEmpty {
                        Text("沒有符合的評論")
                            .foregroundStyle(AppColors.shared.secondaryText)
                    } else {
                        ForEach(matchedReviews) { review in
                            NavigationLink {
                                ReviewDetailView(review: review)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(review.target?.name ?? "未命名目標")
                                        .font(.headline)
                                    Text(review.comment.nilIfEmpty ?? "沒有評論文字")
                                        .lineLimit(2)
                                        .foregroundStyle(AppColors.shared.secondaryText)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("搜尋")
        .navigationBarTitleDisplayMode(.inline)
    }
}
