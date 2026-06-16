import SwiftData
import SwiftUI

struct HomeTabView: View {
    let router: AppRouter
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Review.updated, order: .reverse) private var reviews: [Review]
    @State private var filterState = ReviewFilterState()
    @State private var showFilterSheet = false
    @State private var deletingReview: Review?
    @State private var editingReview: Review?
    @State private var viewingReview: Review?
    @State private var creatingReview = false

    private var filteredReviews: [Review] {
        reviews.filter(filterState.matches)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
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
                                    ReviewCardView(review: review)
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
                                        deletingReview = review
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
            .navigationTitle("評論日誌")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        creatingReview = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
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
                get: { deletingReview != nil },
                set: { if !$0 { deletingReview = nil } }
            )) {
                Button("取消", role: .cancel) {
                    deletingReview = nil
                }
                Button("刪除", role: .destructive) {
                    if let deletingReview {
                        deletingReview.target?.reviews.removeAll { $0.id == deletingReview.id }
                        modelContext.delete(deletingReview)
                        try? modelContext.save()
                    }
                    deletingReview = nil
                }
            } message: {
                Text("刪除後將無法復原。")
            }
        }
    }

    private var header: some View {
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
                    badgeCount: filterState.activeFilterCount,
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
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

struct ReviewFilterSheet: View {
    let filterState: ReviewFilterState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
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

                Section("目標類型") {
                    Picker("類型", selection: Bindable(filterState).targetType) {
                        Text("全部").tag(Optional<TargetType>.none)
                        ForEach(TargetType.allCases, id: \.self) { type in
                            Text(type.title).tag(Optional(type))
                        }
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
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ReviewCardView: View {
    let review: Review
    @State private var averageColor = Color.secondary.opacity(0.15)

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(averageColor)

                if let image = uiImage(from: review.primaryPhoto) ?? UIImage(named: "Placeholder") {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Image(.placeholder)
                        .resizable()
                        .scaledToFit()
                        .padding(24)
                }
            }
            .frame(height: 220)
            .task(id: review.id) {
                if let image = uiImage(from: review.primaryPhoto) ?? UIImage(named: "Placeholder"),
                   let color = await extractAverageColor(from: image) {
                    averageColor = color.opacity(0.35)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(review.target?.name ?? "未指定目標")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                HStack {
                    Text(review.target?.type.title ?? "未知類型")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Label(String(format: "%.1f", review.score), systemImage: "star.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.orange)
                }

                Text("第 \(review.reviewCount) 次")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.background)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.secondary.opacity(0.12))
        }
        .shadow(color: .black.opacity(0.06), radius: 18, y: 8)
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
                    .foregroundStyle(.secondary)

                Text(current + (showCursor ? "|" : ""))
                    .foregroundStyle(current.isEmpty ? .secondary : .primary)
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
                .foregroundStyle(.secondary)

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
                .foregroundStyle(isActive ? .white : .primary)
                .frame(width: 44, height: 44)
                .background(
                    isActive ? Color.primary : Color.clear,
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            if badgeCount > 0 {
                Text("\(badgeCount)")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .frame(minWidth: 18, minHeight: 18)
                    .padding(.horizontal, 4)
                    .background(.red, in: Capsule())
                    .offset(x: 6, y: -6)
            }
        }
    }
}
