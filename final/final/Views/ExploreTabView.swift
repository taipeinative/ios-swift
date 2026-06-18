import SwiftData
import SwiftUI

struct ExploreTabView: View {
    @Query(sort: \Review.updated, order: .reverse) private var reviews: [Review]

    @State private var aiAnalysis: AIUserAnalysis?
    @State private var aiAnalysisError: String?
    @State private var isAnalyzing = false

    private var totalPoints: Int {
        reviews.reduce(into: 0) { points, review in
            points += review.comment.count
            points += review.photos.count * 25
        }
    }

    private var currentLevel: Int {
        max(1, totalPoints / 100 + 1)
    }

    private var averageScore: Double? {
        guard !reviews.isEmpty else { return nil }
        return reviews.map(\.score).reduce(0, +) / Double(reviews.count)
    }

    private var averageScoreText: String {
        guard let averageScore else { return "尚未評分" }
        return String(format: "%.1f", averageScore)
    }

    private var totalPhotoCount: Int {
        reviews.reduce(0) { $0 + $1.photos.count }
    }

    private var totalCommentCharacters: Int {
        reviews.reduce(0) { $0 + $1.comment.count }
    }

    private var reviewedTargets: [Target] {
        Array(Dictionary(grouping: reviews.compactMap(\.target), by: \.id).values.compactMap(\.first))
    }

    private var typeInsights: [InsightTypeSummary] {
        TargetType.allCases.compactMap { type in
            let typeReviews = reviews.filter { $0.target?.type == type }
            guard !typeReviews.isEmpty else { return nil }
            let average = typeReviews.map(\.score).reduce(0, +) / Double(typeReviews.count)
            return InsightTypeSummary(type: type, reviewCount: typeReviews.count, averageScore: average)
        }
        .sorted {
            if $0.reviewCount == $1.reviewCount {
                return $0.averageScore > $1.averageScore
            }
            return $0.reviewCount > $1.reviewCount
        }
    }

    private var topTypeInsight: InsightTypeSummary? {
        typeInsights.first
    }

    private var revisitCandidates: [InsightTargetSummary] {
        Dictionary(grouping: reviews.compactMap { review -> (Target, Review)? in
            guard let target = review.target else { return nil }
            return (target, review)
        }, by: { $0.0.id })
        .values
        .compactMap { pairs -> InsightTargetSummary? in
            guard let target = pairs.first?.0 else { return nil }
            let targetReviews = pairs.map(\.1)
            let average = targetReviews.map(\.score).reduce(0, +) / Double(targetReviews.count)
            let lastReviewDate = targetReviews.map(\.created).max() ?? .distantPast
            let lastActionDate = targetReviews.map(\.watched).max() ?? lastReviewDate
            return InsightTargetSummary(
                target: target,
                reviewCount: targetReviews.count,
                averageScore: average,
                lastReviewDate: lastReviewDate,
                lastActionDate: lastActionDate
            )
        }
        .filter { $0.averageScore >= 3.5 }
        .sorted {
            if $0.lastActionDate == $1.lastActionDate {
                return $0.averageScore > $1.averageScore
            }
            return $0.lastActionDate < $1.lastActionDate
        }
    }

    private var aiInputSignature: String {
        reviews
            .prefix(10)
            .map { "\($0.id.uuidString)-\($0.updated.timeIntervalSince1970)" }
            .joined(separator: "|")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    heroSection
                    overviewGrid

                    if reviews.isEmpty {
                        emptyInsightCard
                    } else {
                        aiInsightSection
                        preferenceSection
                        writingSection
                        revisitSection
                    }
                }
                .padding(20)
            }
            .background(AppColors.shared.primarySurface)
            .navigationTitle("洞察")
            .task(id: aiInputSignature) {
                await refreshAIAnalysis()
            }
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("你的評論正在形成輪廓")
                        .font(.title2.bold())
                        .foregroundStyle(AppColors.shared.primaryText)

                    Text(heroDescription)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.shared.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 16)

                VStack(spacing: 3) {
                    Text("Lv.\(currentLevel)")
                        .font(.title3.bold())
                        .foregroundStyle(AppColors.shared.inverseText)

                    Text("目前等級")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppColors.shared.inverseText.opacity(0.78))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppColors.shared.activeControlBackground, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    AppColors.shared.secondaryGroupedSurface,
                    AppColors.shared.tertiaryGroupedSurface
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 30, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(AppColors.shared.standardStroke)
        }
    }

    private var heroDescription: String {
        guard let topTypeInsight else {
            return "新增幾則評論後，這裡會整理你的偏好、寫作節奏和適合重訪的項目。"
        }

        return "目前最明顯的足跡落在「\(topTypeInsight.type.title)」，平均評分 \(String(format: "%.1f", topTypeInsight.averageScore))。"
    }

    private var overviewGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            InsightMetricCard(title: "評論", value: "\(reviews.count)", footnote: "累積紀錄", systemName: "text.bubble.fill")
            InsightMetricCard(title: "對象", value: "\(reviewedTargets.count)", footnote: "已被評論", systemName: "square.stack.3d.up.fill")
            InsightMetricCard(title: "平均評分", value: averageScoreText, footnote: scoreMoodText, systemName: "star.fill")
            InsightMetricCard(title: "照片", value: "\(totalPhotoCount)", footnote: "評論附件", systemName: "photo.stack.fill")
        }
    }

    private var scoreMoodText: String {
        guard let averageScore else { return "等待第一筆資料" }
        switch averageScore {
        case 4.2...:
            return "最近很常遇到好東西"
        case 3.2..<4.2:
            return "整體偏正向"
        case 2.0..<3.2:
            return "評分相當謹慎"
        default:
            return "可能需要換個方向"
        }
    }

    private var emptyInsightCard: some View {
        ContentUnavailableView(
            "還沒有洞察",
            systemImage: "chart.line.text.clipboard",
            description: Text("建立第一篇評論後，這裡會開始顯示你的偏好與回顧線索。")
        )
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity)
        .background(AppColors.shared.secondaryGroupedSurface, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var aiInsightSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            InsightSectionHeader(title: "AI 近期分析", subtitle: "根據最近 10 筆評論與對應目標產生")

            AIInsightSummaryCard(
                analysis: aiAnalysis ?? .placeholder,
                isLoading: isAnalyzing,
                errorMessage: aiAnalysisError
            ) {
                Task {
                    await refreshAIAnalysis()
                }
            }
        }
    }

    private var preferenceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            InsightSectionHeader(title: "偏好輪廓", subtitle: "依照分類整理你的評論密度與平均分數")

            VStack(spacing: 12) {
                ForEach(typeInsights) { insight in
                    InsightTypeRow(insight: insight, maxCount: max(typeInsights.map(\.reviewCount).max() ?? 1, 1))
                }
            }
        }
    }

    private var writingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            InsightSectionHeader(title: "寫作軌跡", subtitle: "從文字與照片看見你記錄事物的方式")

            HStack(spacing: 12) {
                InsightWritingCard(
                    title: "文字量",
                    value: "\(totalCommentCharacters)",
                    detail: "每 100 字會推進一個等級進度",
                    systemName: "character.textbox"
                )

                InsightWritingCard(
                    title: "影像記憶",
                    value: "\(totalPhotoCount)",
                    detail: "每張照片提供 25 點等級分數",
                    systemName: "camera.aperture"
                )
            }
        }
    }

    private var revisitSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            InsightSectionHeader(title: "值得重訪", subtitle: "從高分且較久未更新的對象開始")

            if revisitCandidates.isEmpty {
                Text("目前還沒有足夠的高分對象可形成重訪建議。")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.shared.secondaryText)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.shared.secondaryGroupedSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(revisitCandidates.prefix(4)) { summary in
                        NavigationLink {
                            TargetDetailView(target: summary.target)
                        } label: {
                            InsightRevisitCard(summary: summary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func refreshAIAnalysis() async {
        guard !reviews.isEmpty else {
            aiAnalysis = nil
            aiAnalysisError = nil
            return
        }

        isAnalyzing = true
        aiAnalysisError = nil
        defer { isAnalyzing = false }

        do {
            let json = try AIInsightService.recentReviewsJSON(from: reviews)

            if #available(iOS 26.0, *) {
                aiAnalysis = try await AIInsightService.analyzeRecentReviews(json: json)
            } else {
                aiAnalysisError = "AI 洞察需要 iOS 26。"
            }
        } catch {
            aiAnalysisError = error.localizedDescription
        }
    }
}

private struct InsightSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(AppColors.shared.primaryText)

            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(AppColors.shared.secondaryText)
        }
    }
}

private struct InsightPill: View {
    let systemName: String
    let title: String

    var body: some View {
        Label(title, systemImage: systemName)
            .font(.caption.weight(.semibold))
            .foregroundStyle(AppColors.shared.secondaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(AppColors.shared.subtleFill, in: Capsule())
    }
}

private struct InsightMetricCard: View {
    let title: String
    let value: String
    let footnote: String
    let systemName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: systemName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(AppColors.shared.secondaryText)

                Spacer()
            }

            Text(value)
                .font(.title.bold())
                .foregroundStyle(AppColors.shared.primaryText)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.shared.primaryText)

                Text(footnote)
                    .font(.caption2)
                    .foregroundStyle(AppColors.shared.secondaryText)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 148, alignment: .leading)
        .background(AppColors.shared.secondaryGroupedSurface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(AppColors.shared.standardStroke)
        }
    }
}

private struct AIInsightSummaryCard: View {
    let analysis: AIUserAnalysis
    let isLoading: Bool
    let errorMessage: String?
    let refresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Label("Foundation Models", systemImage: "sparkles")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.shared.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppColors.shared.subtleFill, in: Capsule())

                Spacer()

                Button {
                    refresh()
                } label: {
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .buttonStyle(.bordered)
                .disabled(isLoading)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.shared.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(analysis.recentReviewSummary)
                    .font(.headline)
                    .foregroundStyle(AppColors.shared.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack(spacing: 10) {
                InsightAnalysisBadge(
                    title: "推測心情",
                    value: analysis.inferredMood.rawValue,
                    systemName: analysis.inferredMood.symbolName,
                    color: analysis.inferredMood.tint
                )

                InsightAnalysisBadge(
                    title: "多涉略",
                    value: analysis.suggestedType.rawValue,
                    systemName: analysis.suggestedType.targetType.exploreSymbolName,
                    color: analysis.suggestedType.targetType.color
                )
            }
        }
        .padding(18)
        .background(AppColors.shared.secondaryGroupedSurface, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(AppColors.shared.standardStroke)
        }
    }
}

private struct InsightAnalysisBadge: View {
    let title: String
    let value: String
    let systemName: String
    let color: Color

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: systemName)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppColors.shared.secondaryText)

                Text(value)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.shared.primaryText)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.shared.faintFill, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct InsightTypeRow: View {
    let insight: InsightTypeSummary
    let maxCount: Int

    private var progress: Double {
        guard maxCount > 0 else { return 0 }
        return Double(insight.reviewCount) / Double(maxCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: insight.type.exploreSymbolName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(insight.type.color)
                    .frame(width: 34, height: 34)
                    .background(insight.type.color.opacity(0.12), in: Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(insight.type.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppColors.shared.primaryText)

                    Text("\(insight.reviewCount) 則評論")
                        .font(.caption)
                        .foregroundStyle(AppColors.shared.secondaryText)
                }

                Spacer()

                Text(String(format: "%.1f", insight.averageScore))
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.shared.score)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColors.shared.subtleFill)

                    Capsule()
                        .fill(insight.type.color.opacity(0.72))
                        .frame(width: max(10, proxy.size.width * progress))
                }
            }
            .frame(height: 8)
        }
        .padding(14)
        .background(AppColors.shared.secondaryGroupedSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct InsightWritingCard: View {
    let title: String
    let value: String
    let detail: String
    let systemName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemName)
                .font(.headline.weight(.semibold))
                .foregroundStyle(AppColors.shared.secondaryText)

            Text(value)
                .font(.title2.bold())
                .foregroundStyle(AppColors.shared.primaryText)

            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(AppColors.shared.primaryText)

            Text(detail)
                .font(.caption2)
                .foregroundStyle(AppColors.shared.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 156, alignment: .leading)
        .background(AppColors.shared.secondaryGroupedSurface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(AppColors.shared.standardStroke)
        }
    }
}

private struct InsightRevisitCard: View {
    let summary: InsightTargetSummary

    var body: some View {
        HStack(spacing: 14) {
            AttachmentImage(attachment: summary.target.primaryPhoto, contentMode: .fill, placeholderPadding: 16)
                .frame(width: 74, height: 74)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(summary.target.name)
                    .font(.headline)
                    .foregroundStyle(AppColors.shared.primaryText)
                    .lineLimit(1)

                Label(summary.target.type.title, systemImage: summary.target.type.exploreSymbolName)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(summary.target.type.color)

                Text("平均 \(String(format: "%.1f", summary.averageScore)) 分・\(summary.reviewCount) 次評論")
                    .font(.caption)
                    .foregroundStyle(AppColors.shared.secondaryText)

                Text("上次\(summary.target.type.actionDateTitle.replacingOccurrences(of: "日期", with: ""))：\(DateFormatter.reviewDate.string(from: summary.lastActionDate))")
                    .font(.caption2)
                    .foregroundStyle(AppColors.shared.tertiaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppColors.shared.tertiaryText)
        }
        .padding(14)
        .background(AppColors.shared.secondaryGroupedSurface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(AppColors.shared.standardStroke)
        }
    }
}

private extension TargetType {
    var exploreSymbolName: String {
        switch self {
        case .book: return "book.closed.fill"
        case .drama: return "theatermasks.fill"
        case .location: return "mappin.and.ellipse"
        case .movie: return "film.fill"
        case .music: return "music.note"
        case .other: return "sparkles"
        }
    }
}

private struct InsightTypeSummary: Identifiable {
    var id: TargetType { type }
    let type: TargetType
    let reviewCount: Int
    let averageScore: Double
}

private struct InsightTargetSummary: Identifiable {
    var id: UUID { target.id }
    let target: Target
    let reviewCount: Int
    let averageScore: Double
    let lastReviewDate: Date
    let lastActionDate: Date
}
