import PhotosUI
import SwiftData
import SwiftUI

struct ReviewLandingView: View {
    let onReviewCreated: ((Review) -> Void)?

    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Target.name, order: .forward) private var targets: [Target]
    @State private var query = ""
    @State private var selectedTarget: Target?
    @State private var showNewTargetSheet = false
    @FocusState private var isSearchFocused: Bool

    private var filteredTargets: [Target] {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return targets
        }

        return targets.filter {
            $0.name.localizedStandardContains(query)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SearchInputBar(placeholder: "搜尋目標名稱", text: $query, isFocused: $isSearchFocused)

                if filteredTargets.isEmpty {
                    ContentUnavailableView(
                        "找不到符合的目標",
                        systemImage: "magnifyingglass",
                        description: Text("可以調整搜尋文字，或直接建立新目標。")
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                } else {
                    Text("選擇要評論的目標")
                        .font(.headline)

                    LazyVStack(spacing: 10) {
                        ForEach(filteredTargets) { target in
                            Button {
                                selectedTarget = target
                            } label: {
                                TargetRowView(target: target)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                                    .background(AppColors.shared.secondaryGroupedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(AppColors.shared.standardStroke)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("新增評論")
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showNewTargetSheet = true
                } label: {
                    Label("新增目標", systemImage: "plus")
                }
            }
        }
        .navigationDestination(item: $selectedTarget) { target in
            ReviewFormView(mode: .create(target: target) { review in
                selectedTarget = nil
                dismiss()
                DispatchQueue.main.async {
                    onReviewCreated?(review)
                }
            })
        }
        .sheet(isPresented: $showNewTargetSheet) {
            NavigationStack {
                TargetFormView(mode: .createForReview { target in
                    selectedTarget = target
                    showNewTargetSheet = false
                })
            }
        }
    }
}

struct TargetRowView: View {
    let target: Target

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let image = uiImage(from: target.primaryPhoto) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(.placeholder)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 68, height: 68)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(target.name)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Text(target.summaryText)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.shared.secondaryText)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TargetFormView: View {
    let mode: TargetFormMode

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    @State private var name = ""
    @State private var type: TargetType = .book
    @State private var descriptions = ""
    @State private var attributes: [AttributeDraft] = []
    @State private var isAttributeExpanded = false
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var photos: [PhotoAttachment] = []

    private var attributePalette: AttributeListPalette {
        AttributeListPalette.colors(for: colorScheme)
    }

    var body: some View {
        Form {
            Section("基本資訊") {
                TextField("名稱", text: $name)
                    .autocorrectionDisabled()

                Picker("類型", selection: $type) {
                    ForEach(TargetType.allCases, id: \.self) { type in
                        Text(type.title).tag(type)
                    }
                }

                MultilineInputField(
                    placeholder: "描述（選填）",
                    text: $descriptions,
                    minHeight: 96
                )
            }

            Section {
                DisclosureGroup("屬性清單", isExpanded: $isAttributeExpanded) {
                    if attributes.isEmpty {
                        Text("尚未加入任何屬性")
                            .foregroundStyle(AppColors.shared.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    ForEach(attributes) { attribute in
                        AttributeEditorRow(
                            attribute: attributeBinding(for: attribute.id),
                            allowedTypes: type.getAttributeTypes(),
                            palette: attributePalette,
                            onDuplicate: {
                                duplicateAttribute(withID: attribute.id)
                            }
                        ) {
                            deleteAttribute(withID: attribute.id)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 4, bottom: 6, trailing: 10))
                        .listRowBackground(attributePalette.listBackground)
                    }

                    Button {
                        attributes.append(AttributeDraft(type: type.getAttributeTypes().first ?? .genre))
                    } label: {
                        Label("新增屬性", systemImage: "plus")
                    }
                    .listRowBackground(attributePalette.listBackground)
                }
                .listRowBackground(attributePalette.listBackground)
            }

            Section("照片（最多 5 張）") {
                PhotoAttachmentEditor(
                    pickerItems: $photoItems,
                    attachments: $photos,
                    limit: 5
                )
            }
        }
        .navigationTitle(mode.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .confirm) {
                    save()
                } label: {
                    Label("儲存", systemImage: "checkmark")
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .task {
            applyInitialValueIfNeeded()
        }
        .onChange(of: photoItems) { _, newValue in
            Task {
                photos = await loadPhotoAttachments(from: newValue, existing: photos)
            }
        }
        .onChange(of: type) { _, newValue in
            attributes = attributes.map { draft in
                var updated = draft
                if !newValue.getAttributeTypes().contains(updated.type) {
                    updated.type = newValue.getAttributeTypes().first ?? .genre
                }
                return updated
            }
        }
    }

    @MainActor
    private func applyInitialValueIfNeeded() {
        guard name.isEmpty else { return }

        if case let .edit(target) = mode {
            name = target.name
            type = target.type
            descriptions = target.descriptions ?? ""
            attributes = target.attributes.map(AttributeDraft.init)
            photos = target.photos
        }
    }

    private func save() {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedDescription = descriptions.nilIfEmpty
        let normalizedAttributes = attributes.map(\.data)

        switch mode {
        case let .create(onSaved):
            let target = Target(
                name: normalizedName,
                type: type,
                attributes: normalizedAttributes,
                description: normalizedDescription,
                photos: Array(photos.prefix(5))
            )
            modelContext.insert(target)
            onSaved?(target)
            if onSaved == nil {
                dismiss()
            }

        case let .createForReview(handler):
            let target = Target(
                name: normalizedName,
                type: type,
                attributes: normalizedAttributes,
                description: normalizedDescription,
                photos: Array(photos.prefix(5))
            )
            modelContext.insert(target)
            handler(target)

        case let .edit(target):
            target.name = normalizedName
            target.type = type
            target.descriptions = normalizedDescription
            target.attributes = normalizedAttributes
            target.photos = Array(photos.prefix(5))
            dismiss()
        }

        try? modelContext.save()
    }

    private func duplicateAttribute(withID id: UUID) {
        guard let index = attributes.firstIndex(where: { $0.id == id }) else { return }
        attributes.insert(attributes[index].duplicated(), at: index + 1)
    }

    private func deleteAttribute(withID id: UUID) {
        Task { @MainActor in
            attributes.removeAll { $0.id == id }
        }
    }

    private func attributeBinding(for id: UUID) -> Binding<AttributeDraft> {
        Binding {
            attributes.first { $0.id == id } ?? AttributeDraft(type: type.getAttributeTypes().first ?? .genre)
        } set: { updatedAttribute in
            guard let index = attributes.firstIndex(where: { $0.id == id }) else { return }
            attributes[index] = updatedAttribute
        }
    }
}

struct AttributeEditorRow: View {
    @Binding var attribute: AttributeDraft
    let allowedTypes: [TargetAttributeType]
    let palette: AttributeListPalette
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    @State private var showActions = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Menu {
                    Button {
                        onDuplicate()
                    } label: {
                        Label("複製", systemImage: "plus.square.on.square")
                    }

                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("刪除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(palette.iconTint)
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading) {
                    HStack {
                        Text("屬性")

                        Spacer(minLength: 0)

                        Picker("屬性", selection: $attribute.type) {
                            ForEach(allowedTypes, id: \.self) { type in
                                Text(type.title).tag(type)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .tint(palette.iconTint)
                    }

                    switch attribute.type.inputKind {
                    case .text:
                        TextField("請輸入\(attribute.type.title)", text: $attribute.textValue)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)
                    case .date:
                        DatePicker(attribute.type.title, selection: $attribute.dateValue, displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    case .link:
                        TextField("顯示文字", text: $attribute.textValue)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)
                        TextField("網址", text: $attribute.secondaryText)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14)
        .background(palette.cardBackground, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(palette.cardStroke)
        }
        .contentShape(.interaction, RoundedRectangle(cornerRadius: 18, style: .continuous))
        .highPriorityGesture(
            LongPressGesture(minimumDuration: 0.45)
                .onEnded { _ in
                    showActions = true
                }
        )
        .confirmationDialog("屬性選項", isPresented: $showActions) {
            Button {
                onDuplicate()
            } label: {
                Label("複製", systemImage: "plus.square.on.square")
            }

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("刪除", systemImage: "trash")
            }
        }
    }
}

struct PhotoAttachmentEditor: View {
    @Binding var pickerItems: [PhotosPickerItem]
    @Binding var attachments: [PhotoAttachment]
    let limit: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PhotosPicker(
                selection: $pickerItems,
                maxSelectionCount: limit,
                matching: .images
            ) {
                Label("選擇照片", systemImage: "photo.on.rectangle")
            }
            .disabled(attachments.count >= limit)

            if !attachments.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(attachments) { attachment in
                            ZStack(alignment: .topTrailing) {
                                if let image = UIImage(data: attachment.data) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 92, height: 92)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }

                                Button {
                                    attachments.removeAll { $0.id == attachment.id }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(AppColors.shared.inverseText, AppColors.shared.dimOverlay)
                                }
                                .offset(x: 6, y: -6)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct PhotoGalleryViewer: View {
    let attachments: [PhotoAttachment]
    let initialIndex: Int

    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex: Int

    init(attachments: [PhotoAttachment], initialIndex: Int) {
        self.attachments = attachments
        self.initialIndex = initialIndex
        _selectedIndex = State(initialValue: initialIndex)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.shared.fullScreenBackdrop.ignoresSafeArea()

                TabView(selection: $selectedIndex) {
                    ForEach(Array(attachments.enumerated()), id: \.offset) { index, attachment in
                        ZStack {
                            if let image = UIImage(data: attachment.data) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .tag(index)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.shared.inverseText)
                }

                ToolbarItem(placement: .principal) {
                    Text("\(selectedIndex + 1) / \(attachments.count)")
                        .foregroundStyle(AppColors.shared.inverseText)
                        .font(.subheadline.weight(.semibold))
                }
            }
        }
    }
}

struct ReviewFormView: View {
    let mode: ReviewFormMode

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var target: Target?
    @State private var score = 3.0
    @State private var reviewCount = 1
    @State private var watched = Date.now
    @State private var comment = ""
    @State private var photoItems: [PhotosPickerItem] = []
    @State private var photos: [PhotoAttachment] = []
    @State private var showTargetPicker = false

    var body: some View {
        Form {
            Section("目標") {
                if let target {
                    Button {
                        showTargetPicker = true
                    } label: {
                        HStack(spacing: 12) {
                            Group {
                                if let image = uiImage(from: target.primaryPhoto) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                } else {
                                    Image(.placeholder)
                                        .resizable()
                                        .scaledToFill()
                                }
                            }
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                            VStack(alignment: .leading, spacing: 6) {
                                Text(target.name)
                                    .font(.headline)
                                    .foregroundStyle(AppColors.shared.primaryText)
                                    .lineLimit(2)

                                Text(target.summaryText)
                                    .font(.subheadline)
                                    .foregroundStyle(AppColors.shared.secondaryText)
                                    .lineLimit(2)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(AppColors.shared.tertiaryText)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }

            Section("評分") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("分數")
                        Spacer()
                        HStack {
                            Label(String(format: "%.1f / 5.0 分", score), systemImage: "star.fill")
                                .foregroundStyle(AppColors.shared.score)
                        }
                    }

                    Slider(value: $score, in: 0...5, step: 0.1)
                }

                Stepper(value: $reviewCount, in: 1...9999) {
                    Text("第 \(reviewCount) 次")
                }

                DatePicker(target?.type.actionDateTitle ?? "日期", selection: $watched, displayedComponents: .date)
            }

            Section("心得") {
                MultilineInputField(
                    placeholder: "寫下你的評論",
                    text: $comment,
                    minHeight: 144
                )
            }

            Section("附圖（最多 5 張）") {
                PhotoAttachmentEditor(pickerItems: $photoItems, attachments: $photos, limit: 5)
            }
        }
        .navigationTitle(mode.title)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .confirm) {
                    save()
                } label: {
                    Label("儲存", systemImage: "checkmark")
                }
                .disabled(target == nil)
            }
        }
        .task {
            applyInitialValueIfNeeded()
        }
        .onChange(of: photoItems) { _, newValue in
            Task {
                photos = await loadPhotoAttachments(from: newValue, existing: photos)
            }
        }
        .onChange(of: target?.id) { _, _ in
            if case .create(_, _) = mode, let target {
                reviewCount = nextReviewCount(for: target)
            }
        }
        .sheet(isPresented: $showTargetPicker) {
            NavigationStack {
                TargetPickerView(selectedTarget: $target)
            }
        }
    }

    @MainActor
    private func applyInitialValueIfNeeded() {
        guard target == nil else { return }

        switch mode {
        case let .create(target, _):
            self.target = target
            watched = .now
            reviewCount = nextReviewCount(for: target)

        case let .edit(review):
            target = review.target
            score = review.score
            reviewCount = review.reviewCount
            watched = review.watched
            comment = review.comment
            photos = review.photos
        }
    }

    private func save() {
        guard let target else { return }

        switch mode {
        case let .create(_, onSaved):
            let review = Review(
                target: target,
                score: score,
                comment: comment,
                created: .now,
                watched: watched,
                count: reviewCount,
                photos: Array(photos.prefix(5))
            )
            target.reviews.append(review)
            modelContext.insert(review)
            try? modelContext.save()
            onSaved?(review)
            dismiss()

        case let .edit(review):
            let previousTarget = review.target
            if previousTarget?.id != target.id {
                previousTarget?.reviews.removeAll { $0.id == review.id }
                target.reviews.append(review)
            }
            review.target = target
            review.score = score
            review.comment = comment
            review.reviewCount = reviewCount
            review.watched = watched
            review.photos = Array(photos.prefix(5))
            review.updated = .now
            try? modelContext.save()
            dismiss()
        }
    }

    private func nextReviewCount(for target: Target) -> Int {
        (target.reviews.map(\.reviewCount).max() ?? 0) + 1
    }
}

struct TargetPickerView: View {
    @Binding var selectedTarget: Target?
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Target.name, order: .forward) private var targets: [Target]
    @State private var query = ""
    @State private var showNewTargetSheet = false
    @FocusState private var isSearchFocused: Bool

    private var filteredTargets: [Target] {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return targets
        }

        return targets.filter { $0.name.localizedStandardContains(query) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SearchInputBar(placeholder: "搜尋目標名稱", text: $query, isFocused: $isSearchFocused)

                if filteredTargets.isEmpty {
                    ContentUnavailableView(
                        "找不到符合的目標",
                        systemImage: "magnifyingglass",
                        description: Text("可以改用其他關鍵字，或直接新增目標。")
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                } else {
                    Text("選擇目標")
                        .font(.headline)

                    LazyVStack(spacing: 10) {
                        ForEach(filteredTargets) { target in
                            Button {
                                selectedTarget = target
                                dismiss()
                            } label: {
                                TargetRowView(target: target)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                                    .background(AppColors.shared.secondaryGroupedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(AppColors.shared.standardStroke)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("選擇目標")
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showNewTargetSheet = true
                } label: {
                    Label("新增目標", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showNewTargetSheet) {
            NavigationStack {
                TargetFormView(mode: .createForReview { target in
                    selectedTarget = target
                    showNewTargetSheet = false
                    dismiss()
                })
            }
        }
    }
}
