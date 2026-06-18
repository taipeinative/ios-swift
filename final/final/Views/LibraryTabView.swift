import SwiftData
import SwiftUI

struct LibraryTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Target.name, order: .forward) private var targets: [Target]

    @State private var nameQuery = ""
    @State private var attributeQuery = ""
    @State private var selectedTargetType: TargetType?
    @State private var selectedAttributeType: TargetAttributeType?
    @State private var targetToView: Target?
    @State private var targetToEdit: Target?
    @State private var targetToDelete: Target?
    @State private var isCreatingTarget = false
    @FocusState private var isNameFilterFocused: Bool
    @FocusState private var isAttributeFilterFocused: Bool

    private let cardColumns = [
        GridItem(.adaptive(minimum: 260), spacing: 16)
    ]

    private var filteredTargets: [Target] {
        targets.filter { target in
            matchesName(target)
                && matchesTargetType(target)
                && matchesAttribute(target)
        }
    }

    var body: some View {
        NavigationStack {
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
                            description: Text("可以調整名稱、種類或屬性篩選條件。")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 48)
                    } else {
                        LazyVGrid(columns: cardColumns, spacing: 16) {
                            ForEach(filteredTargets) { target in
                                NavigationLink {
                                    TargetDetailView(target: target)
                                } label: {
                                    LibraryTargetCard(target: target)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button {
                                        targetToView = target
                                    } label: {
                                        Label("檢視", systemImage: "eye")
                                    }

                                    Button {
                                        targetToEdit = target
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
                        isCreatingTarget = true
                    } label: {
                        Label("新增目標", systemImage: "plus")
                    }
                }
            }
            .navigationDestination(isPresented: $isCreatingTarget) {
                TargetFormView(mode: .create { target in
                    isCreatingTarget = false
                    DispatchQueue.main.async {
                        targetToView = target
                    }
                })
            }
            .navigationDestination(item: $targetToView) { target in
                TargetDetailView(target: target)
            }
            .navigationDestination(item: $targetToEdit) { target in
                TargetFormView(mode: .edit(target: target))
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

    private var filterPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            SearchInputBar(placeholder: "以名稱篩選", text: $nameQuery, isFocused: $isNameFilterFocused)

            HStack(spacing: 12) {
                filterPicker(title: "種類", systemImage: "square.grid.2x2") {
                    Picker("種類", selection: $selectedTargetType) {
                        Text("全部種類").tag(nil as TargetType?)
                        ForEach(TargetType.allCases, id: \.self) { type in
                            Text(type.title).tag(Optional(type))
                        }
                    }
                }

                filterPicker(title: "屬性", systemImage: "tag") {
                    Picker("屬性", selection: $selectedAttributeType) {
                        Text("全部屬性").tag(nil as TargetAttributeType?)
                        ForEach(TargetAttributeType.allCases, id: \.self) { type in
                            Text(type.title).tag(Optional(type))
                        }
                    }
                }
            }

            SearchInputBar(placeholder: "以屬性內容篩選", text: $attributeQuery, isFocused: $isAttributeFilterFocused)
        }
        .padding(16)
        .background(AppColors.shared.secondaryGroupedSurface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func filterPicker<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundStyle(AppColors.shared.secondaryText)

            content()
                .pickerStyle(.menu)
                .tint(AppColors.shared.primaryText)
        }
        .font(.subheadline.weight(.semibold))
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(AppColors.shared.primarySurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColors.shared.standardStroke)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }

    private func matchesName(_ target: Target) -> Bool {
        let query = nameQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
        return target.name.localizedStandardContains(query)
    }

    private func matchesTargetType(_ target: Target) -> Bool {
        guard let selectedTargetType else { return true }
        return target.type == selectedTargetType
    }

    private func matchesAttribute(_ target: Target) -> Bool {
        let query = attributeQuery.trimmingCharacters(in: .whitespacesAndNewlines).localizedLowercase

        guard selectedAttributeType != nil || !query.isEmpty else {
            return true
        }

        return target.attributes.contains { attribute in
            let typeMatches = selectedAttributeType == nil || attribute.type == selectedAttributeType
            let searchableText = [
                attribute.type.title,
                attribute.displayValue,
                attribute.secondaryValue ?? ""
            ]
            .joined(separator: " ")
            .localizedLowercase

            let queryMatches = query.isEmpty || searchableText.contains(query)
            return typeMatches && queryMatches
        }
    }

    private func delete(_ target: Target) {
        for review in target.reviews {
            modelContext.delete(review)
        }
        modelContext.delete(target)
        try? modelContext.save()
    }
}

private struct LibraryTargetCard: View {
    let target: Target

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Group {
                if let image = uiImage(from: target.primaryPhoto) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(.placeholder)
                        .resizable()
                        .scaledToFit()
                        .padding(28)
                        .background(AppColors.shared.defaultImageAverageFill)
                }
            }
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
//                    .padding(.vertical, 7)
                    
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
