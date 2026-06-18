import SwiftData
import SwiftUI

struct LibraryTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Target.name, order: .forward) private var targets: [Target]

    @State private var navigationPath: [LibraryRoute] = []
    @State private var filterState = LibraryFilterState()
    @State private var targetToDelete: Target?
    @State private var showFilterSheet = false
    @FocusState private var isKeywordFocused: Bool

    private let cardColumns = [
        GridItem(.adaptive(minimum: 260), spacing: 16)
    ]

    private var filteredTargets: [Target] {
        targets.filter(filterState.matches)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    filterPanel

                    if targets.isEmpty {
                        ContentUnavailableView(
                            "資料庫是空的",
                            systemImage: "tray",
                            description: Text("建立目標後，它們會集中顯示在這裡。")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 48)
                    } else if filteredTargets.isEmpty {
                        ContentUnavailableView(
                            "沒有符合的目標",
                            systemImage: "line.3.horizontal.decrease.circle",
                            description: Text("可以調整搜尋關鍵字或篩選條件。")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 48)
                    } else {
                        LazyVGrid(columns: cardColumns, spacing: 16) {
                            ForEach(filteredTargets) { target in
                                LibraryTargetCard(target: target)
                                    .contentShape(.interaction, RoundedRectangle(cornerRadius: 24, style: .continuous))
                                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 24, style: .continuous))
                                    .onTapGesture {
                                        navigationPath.append(.detail(target.id))
                                    }
                                    .contextMenu {
                                        Button {
                                            navigationPath.append(.detail(target.id))
                                        } label: {
                                            Label("檢視", systemImage: "eye")
                                        }

                                        Button {
                                            navigationPath.append(.edit(target.id))
                                        } label: {
                                            Label("編輯", systemImage: "square.and.pencil")
                                        }

                                        Button(role: .destructive) {
                                            targetToDelete = target
                                        } label: {
                                            Label("刪除", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .zIndex(0)
                    }
                }
                .padding(20)
            }
            .background(AppColors.shared.primarySurface)
            .navigationTitle("資料庫")
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        navigationPath.append(.create)
                    } label: {
                        Label("新增目標", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                LibraryFilterSheet(filterState: filterState)
                    .presentationDetents([.medium, .large])
            }
            .navigationDestination(for: LibraryRoute.self) { route in
                destination(for: route)
            }
            .alert("確定刪除此目標與其所有評論嗎？", isPresented: Binding(
                get: { targetToDelete != nil },
                set: { if !$0 { targetToDelete = nil } }
            )) {
                Button("取消", role: .cancel) {
                    targetToDelete = nil
                }
                Button("刪除", role: .destructive) {
                    if let targetToDelete {
                        delete(targetToDelete)
                    }
                    targetToDelete = nil
                }
            } message: {
                Text("刪除後將無法復原。")
            }
        }
    }

    @ViewBuilder
    private func destination(for route: LibraryRoute) -> some View {
        switch route {
        case .create:
            TargetFormView(mode: .create { target in
                navigationPath = [.detail(target.id)]
            })
        case let .detail(targetID):
            if let target = target(withID: targetID) {
                TargetDetailView(target: target)
            } else {
                ContentUnavailableView("找不到目標", systemImage: "questionmark.folder")
            }
        case let .edit(targetID):
            if let target = target(withID: targetID) {
                TargetFormView(mode: .edit(target: target))
            } else {
                ContentUnavailableView("找不到目標", systemImage: "questionmark.folder")
            }
        }
    }

    private var filterPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                SearchInputBar(
                    placeholder: "搜尋關鍵字",
                    text: Bindable(filterState).keyword,
                    isFocused: $isKeywordFocused
                )
                .contentShape(.interaction, RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button {
                    showFilterSheet = true
                } label: {
                    CircleIconButton(
                        systemName: filterState.activeFilterCount > 0 ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle",
                        isActive: filterState.activeFilterCount > 0
                    )
                }
                .buttonStyle(.plain)
                .contentShape(.interaction, RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            if filterState.activeConditionCount > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        activeConditionChips
                    }
                    .padding(.vertical, 2)
                }
                .scrollClipDisabled()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.shared.primarySurface.opacity(0.001))
        .contentShape(.interaction, Rectangle())
        .zIndex(10)
    }

    @ViewBuilder
    private var activeConditionChips: some View {
        if filterState.hasKeywordFilter {
            FilterChip(title: "關鍵字：\(filterState.keyword.trimmingCharacters(in: .whitespacesAndNewlines))") {
                filterState.keyword = ""
            }
        }

        if filterState.reviewDateRange != .all {
            FilterChip(title: reviewDateRangeChipTitle) {
                filterState.reviewDateRange = .all
            }
        }

        if let targetType = filterState.targetType {
            TargetTypeFilterChip(type: targetType) {
                filterState.targetType = nil
            }
        }

        if filterState.hasReviewCountFilter {
            FilterChip(title: "評論數：\(filterState.comparison.title) \(filterState.reviewCount)") {
                filterState.comparison = .greaterOrEqual
                filterState.reviewCount = 1
            }
        }
    }

    private var reviewDateRangeChipTitle: String {
        if filterState.reviewDateRange == .custom {
            let start = DateFormatter.reviewDate.string(from: min(filterState.customStartDate, filterState.customEndDate))
            let end = DateFormatter.reviewDate.string(from: max(filterState.customStartDate, filterState.customEndDate))
            return "評論日期：\(start) - \(end)"
        }

        return "評論日期：\(filterState.reviewDateRange.title)"
    }

    private func delete(_ target: Target) {
        for review in target.reviews {
            modelContext.delete(review)
        }
        modelContext.delete(target)
        try? modelContext.save()
    }

    private func target(withID id: UUID) -> Target? {
        targets.first { $0.id == id }
    }
}

private enum LibraryRoute: Hashable {
    case create
    case detail(UUID)
    case edit(UUID)
}

private struct LibraryFilterSheet: View {
    let filterState: LibraryFilterState
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
                    Picker("", selection: Bindable(filterState).reviewDateRange) {
                        ForEach(ReviewUpdatedRange.allCases) { range in
                            Text(range.title).tag(range)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()

                    if filterState.reviewDateRange == .custom {
                        DatePicker("開始日", selection: Bindable(filterState).customStartDate, displayedComponents: .date)
                        DatePicker("截止日", selection: Bindable(filterState).customEndDate, displayedComponents: .date)
                    }
                }

                Section("評論數") {
                    Picker("條件", selection: Bindable(filterState).comparison) {
                        ForEach(ReviewCountComparison.allCases) { comparison in
                            Text(comparison.title).tag(comparison)
                        }
                    }
                    Stepper(value: Bindable(filterState).reviewCount, in: 1...9999) {
                        Text("數量：\(filterState.reviewCount)")
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

struct TargetTypeFilterChip: View {
    let type: TargetType
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: type.librarySymbolName)
                .font(.caption.weight(.bold))
                .foregroundStyle(type.color)

            Text(type.title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColors.shared.primaryText)
                .lineLimit(1)

            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(AppColors.shared.secondaryText)
                    .frame(width: 16, height: 16)
                    .background(AppColors.shared.subtleFill, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("移除目標分類：\(type.title)")
        }
        .padding(.leading, 10)
        .padding(.trailing, 6)
        .padding(.vertical, 5)
        .background(type.color.opacity(0.12), in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(type.color.opacity(0.22))
        }
    }
}

struct FilterChip: View {
    let title: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColors.shared.primaryText)
                .lineLimit(1)

            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(AppColors.shared.secondaryText)
                    .frame(width: 16, height: 16)
                    .background(AppColors.shared.subtleFill, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("移除\(title)")
        }
        .padding(.leading, 10)
        .padding(.trailing, 6)
        .padding(.vertical, 5)
        .background(AppColors.shared.secondaryGroupedSurface, in: Capsule())
        .overlay {
            Capsule()
                .strokeBorder(AppColors.shared.standardStroke)
        }
    }
}

private struct LibraryTargetCard: View {
    let target: Target

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AttachmentImage(attachment: target.primaryPhoto, contentMode: .fill, placeholderPadding: 28)
            .frame(height: 170)
            .frame(maxWidth: .infinity)
            .clipped()

            VStack(alignment: .leading, spacing: 5) {
                Text(target.name)
                    .font(.headline)
                    .foregroundStyle(AppColors.shared.primaryText)
                    .lineLimit(2)

                Text(target.summaryText)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.shared.secondaryText)
                    .lineLimit(2)
                    .padding(.bottom, 5)

                HStack(spacing: 10) {
                    HStack(alignment: .center) {
                        Image(systemName: target.type.librarySymbolName)
                            .foregroundStyle(target.type.color)
                        
                        Text(target.type.title)
                            .font(.caption.weight(.bold))
                    }
                    
                    Label("\(target.reviews.count) 則評論", systemImage: "text.bubble")

                    if !target.attributes.isEmpty {
                        Label("\(target.attributes.count) 個屬性", systemImage: "tag")
                    }
                }
                .font(.caption.weight(.medium))
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

private extension TargetType {
    var librarySymbolName: String {
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
