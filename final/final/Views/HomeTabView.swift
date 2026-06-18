import SwiftData
import SwiftUI

struct HomeTabView: View {
    let router: AppRouter
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Review.updated, order: .reverse) private var reviews: [Review]
    @State private var filterState = ReviewFilterState()
    @State private var showFilterSheet = false
    @State private var deletingReviewID: UUID?
    @State private var editingReview: Review?
    @State private var viewingReview: Review?
    @State private var creatingReview = false
    @State private var refreshToken = UUID()

    private var filteredReviews: [Review] {
        reviews.filter(filterState.matches)
    }

    private var currentLevel: Int {
        let totalPoints = reviews.reduce(into: 0) { partialResult, review in
            partialResult += review.comment.count
            partialResult += review.photos.count * 25
        }
        return max(1, totalPoints / 100 + 1)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    titleRow
                    header

                    if filteredReviews.isEmpty {
                        ContentUnavailableView(
                            "目前沒有評論",
                            systemImage: "text.bubble",
                            description: Text("新增一則評論後，最近評論會顯示在這裡。")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 48)
                    } else {
                        Text("最近評論")
                            .font(.title3.bold())
                            .padding(.horizontal, 20)

                        LazyVStack(spacing: 18) {
                            ForEach(filteredReviews) { review in
                                NavigationLink {
                                    ReviewDetailView(review: review)
                                } label: {
                                    ReviewCardView(review: review, refreshToken: refreshToken)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button {
                                        viewingReview = review
                                    } label: {
                                        Label("查看", systemImage: "eye")
                                    }

                                    Button {
                                        editingReview = review
                                    } label: {
                                        Label("編輯", systemImage: "square.and.pencil")
                                    }

                                    Button(role: .destructive) {
                                        deletingReviewID = review.id
                                    } label: {
                                        Label("刪除", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
            .refreshable {
                refreshToken = UUID()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        creatingReview = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                ReviewFilterSheet(filterState: filterState)
                    .presentationDetents([.medium, .large])
            }
            .navigationDestination(item: $editingReview) { review in
                ReviewFormView(mode: .edit(review: review))
            }
            .navigationDestination(item: $viewingReview) { review in
                ReviewDetailView(review: review)
            }
            .navigationDestination(isPresented: $creatingReview) {
                ReviewLandingView { review in
                    creatingReview = false
                    viewingReview = review
                }
            }
            .alert("確定要刪除這則評論嗎？", isPresented: Binding(
                get: { deletingReviewID != nil },
                set: { if !$0 { deletingReviewID = nil } }
            )) {
                Button("取消", role: .cancel) {
                    deletingReviewID = nil
                }
                Button("刪除", role: .destructive) {
                    if let deletingReviewID {
                        deleteReview(withID: deletingReviewID)
                    }
                    deletingReviewID = nil
                }
            } message: {
                Text("刪除後將無法復原。")
            }
        }
    }

    private var titleRow: some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            HStack(alignment: .center) {
                Text(greeting(for: timeline.date))
                    .font(.largeTitle.bold())
                    .foregroundStyle(AppColors.shared.primaryText)

                Spacer(minLength: 16)

                Text("Lv. \(currentLevel)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.shared.levelProgress)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(AppColors.shared.levelProgress.opacity(0.12), in: Capsule())
                    .overlay {
                        Capsule()
                            .strokeBorder(AppColors.shared.levelProgress.opacity(0.22))
                    }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
        }
    }

    private func greeting(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)

        switch hour {
        case 6..<12:
            return "早安"
        case 12..<18:
            return "午安"
        default:
            return "晚安"
        }
    }

    private func deleteReview(withID id: UUID) {
        guard let review = reviews.first(where: { $0.id == id }) else { return }

        if let target = review.target {
            let targetID = target.id
            target.reviews = reviews.filter { candidate in
                candidate.id != id && candidate.target?.id == targetID
            }
        }

        modelContext.delete(review)
        try? modelContext.save()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Button {
                    router.selectedTab = .search
                } label: {
                    AnimatedSearchButton()
                }
                .buttonStyle(.plain)

                Button {
                    showFilterSheet = true
                } label: {
                    CircleIconButton(
                        systemName: filterState.activeFilterCount > 0 ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle",
                        isActive: filterState.activeFilterCount > 0
                    )
                }
                .buttonStyle(.plain)

                NavigationLink {
                    SettingsView()
                } label: {
                    CircleIconButton(systemName: "gearshape")
                }
                .buttonStyle(.plain)
            }

            if filterState.activeFilterCount > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        activeFilterChips
                    }
                    .padding(.vertical, 2)
                }
                .scrollClipDisabled()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 0)
    }

    @ViewBuilder
    private var activeFilterChips: some View {
        if filterState.updatedRange != .all {
            FilterChip(title: updatedRangeChipTitle) {
                filterState.updatedRange = .all
            }
        }

        if let targetType = filterState.targetType {
            TargetTypeFilterChip(type: targetType) {
                filterState.targetType = nil
            }
        }

        if filterState.hasReviewCountFilter {
            FilterChip(title: "評論次數：\(filterState.comparison.title) \(filterState.reviewCount)") {
                filterState.comparison = .greaterOrEqual
                filterState.reviewCount = 1
            }
        }
    }

    private var updatedRangeChipTitle: String {
        if filterState.updatedRange == .custom {
            let start = DateFormatter.reviewDate.string(from: min(filterState.customStartDate, filterState.customEndDate))
            let end = DateFormatter.reviewDate.string(from: max(filterState.customStartDate, filterState.customEndDate))
            return "評論日期：\(start) - \(end)"
        }

        return "評論日期：\(filterState.updatedRange.title)"
    }
}

struct ReviewFilterSheet: View {
    let filterState: ReviewFilterState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("分類") {
                    Picker("分類", selection: Bindable(filterState).targetType) {
                        Text("全部").tag(Optional<TargetType>.none)
                        ForEach(TargetType.allCases, id: \.self) { type in
                            Text(type.title).tag(Optional(type))
                        }
                    }
                }
                
                Section("評論日期") {
                    Picker("", selection: Bindable(filterState).updatedRange) {
                        ForEach(ReviewUpdatedRange.allCases) { range in
                            Text(range.title).tag(range)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()

                    if filterState.updatedRange == .custom {
                        DatePicker("開始日", selection: Bindable(filterState).customStartDate, displayedComponents: .date)
                        DatePicker("截止日", selection: Bindable(filterState).customEndDate, displayedComponents: .date)
                    }
                }

                Section("評論次數") {
                    Picker("條件", selection: Bindable(filterState).comparison) {
                        ForEach(ReviewCountComparison.allCases) { comparison in
                            Text(comparison.title).tag(comparison)
                        }
                    }
                    Stepper(value: Bindable(filterState).reviewCount, in: 1...9999) {
                        Text("次數：\(filterState.reviewCount)")
                    }
                }
            }
            .navigationTitle("篩選")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Label("完成", systemImage: "checkmark")
                    }
                }
            }
        }
    }
}

struct ReviewCardView: View {
    let review: Review
    let refreshToken: UUID
    @State private var averageColor = AppColors.shared.defaultImageAverageFill

    private var imageRefreshKey: String {
        refreshToken.uuidString
    }

    private var averageColorTaskID: String {
        "\(review.id.uuidString)-\(review.primaryPhoto?.id.uuidString ?? "none")-\(imageRefreshKey)"
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(averageColor)

                AttachmentImage(
                    attachment: review.primaryPhoto,
                    contentMode: .fit,
                    placeholderPadding: 24,
                    refreshKey: imageRefreshKey
                )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 220)
            .task(id: averageColorTaskID) {
                if let color = await extractAverageColorColorKit(from: review.primaryPhoto) {
                    averageColor = color.opacity(0.35)
                } else {
                    averageColor = AppColors.shared.defaultImageAverageFill
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(review.target?.name ?? "未指定目標")
                    .font(.headline)
                    .foregroundStyle(AppColors.shared.primaryText)
                    .lineLimit(2)

                HStack {
                    Text(review.target?.type.title ?? "未知類型")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.shared.secondaryText)

                    Spacer()

                    Label(String(format: "%.1f", review.score), systemImage: "star.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(AppColors.shared.score)
                }

                Text("第 \(review.reviewCount) 次")
                    .font(.caption)
                    .foregroundStyle(AppColors.shared.secondaryText)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.shared.secondaryGroupedSurface)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(AppColors.shared.standardStroke)
        }
        .shadow(color: AppColors.shared.cardShadow, radius: 18, y: 8)
    }
}

struct AnimatedSearchButton: View {
    private let prompts = ["電影心得", "旅行筆記", "最愛專輯", "讀書紀錄"]

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.12, paused: false)) { context in
            let elapsed = Int(context.date.timeIntervalSinceReferenceDate * 10)
            let termIndex = (elapsed / 24) % prompts.count
            let characterCount = elapsed % 24
            let prompt = prompts[termIndex]
            let visibleLength = min(max(characterCount, 0), prompt.count)
            let current = String(prompt.prefix(visibleLength))
            let showCursor = characterCount < 20 && characterCount.isMultiple(of: 2)

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppColors.shared.secondaryText)

                Text(current + (showCursor ? "|" : ""))
                    .foregroundStyle(current.isEmpty ? AppColors.shared.secondaryText : AppColors.shared.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.subheadline)
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

struct SearchInputBar: View {
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColors.shared.secondaryText)

            TextField(placeholder, text: $text)
                .focused($isFocused)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .font(.subheadline)
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .frame(maxWidth: .infinity)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct CircleIconButton: View {
    let systemName: String
    var badgeCount: Int = 0
    var isActive: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: systemName)
                .font(.title3)
                .foregroundStyle(isActive ? AppColors.shared.inverseText : AppColors.shared.primaryText)
                .frame(width: 44, height: 44)
                .background(
                    isActive ? AppColors.shared.activeControlBackground : AppColors.shared.transparent,
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            if badgeCount > 0 {
                Text("\(badgeCount)")
                    .font(.caption2.bold())
                    .foregroundStyle(AppColors.shared.inverseText)
                    .frame(minWidth: 18, minHeight: 18)
                    .padding(.horizontal, 4)
                    .background(AppColors.shared.destructive, in: Capsule())
                    .offset(x: 6, y: -6)
            }
        }
    }
}
