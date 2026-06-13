import SwiftUI

struct EditPage: View {
    struct UIAttributeRow: Identifiable {
        let id = UUID()
        var type: ReviewAttributeType
        var textValue: String = ""       // Used for basic text attributes
        var linkTitle: String = ""       // Used specifically for .link display name
        var linkURLString: String = ""   // Used specifically for .link web address
    }
    
    // Intermediary UI state mapping struct for editing individual reviews smoothly
    struct UIReviewRow: Identifiable {
        let id: UUID                     // Matches the underlying Review object's ID or newly generated for additions
        var date: Date
        var reviewCount: Int
        var score: Float
        var comment: String
    }
    
    let target: ReviewTarget
    var onDismiss: (ReviewTarget?) -> Void
    
    // Core state properties driving the upper inputs
    @State private var name: String
    @State private var targetComment: String // ✅ Top-level overall target description state
    @State private var reviewType: ReviewType
    @State private var uiAttributes: [UIAttributeRow] = []
    
    // Core state properties driving the lower reviews section
    @State private var isReserved: Bool
    @State private var uiReviews: [UIReviewRow] = []
    @State private var selectedReviewFilterIndex: Int? = nil // Tracks selection for the sub-menu dropdown
    
    // UI layout tracking states
    @State private var isAttributesExpanded: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    init(_ target: ReviewTarget, onDismiss: @escaping (ReviewTarget?) -> Void) {
        self.target = target
        self.onDismiss = onDismiss
        self._name = State(initialValue: target.name)
        self._targetComment = State(initialValue: target.description ?? "") // ✅ Mapping overall target description text
        self._reviewType = State(initialValue: target.type)
        
        // 1. Safe reservation check rule assignment
        // If there are existing historical logs present, force reserve flag down to false
        self._isReserved = State(initialValue: target.reviews.isEmpty)
        
        // Flatten the attributes data on component initialization
        var parsedRows: [UIAttributeRow] = []
        for attr in target.attributes {
            if let keyValueAttr = attr as? ReviewAttributeKeyValue {
                for (title, url) in keyValueAttr.values {
                    parsedRows.append(UIAttributeRow(type: attr.type, linkTitle: title, linkURLString: url))
                }
            } else if let valueAttr = attr as? ReviewAttributeValue {
                for value in valueAttr.values {
                    parsedRows.append(UIAttributeRow(type: attr.type, textValue: value))
                }
            }
        }
        self._uiAttributes = State(initialValue: parsedRows)
        
        // Flatten historical reviews data into editable value configurations
        let parsedReviews = target.reviews.map { review in
            UIReviewRow(
                id: review.id,
                date: review.watched,
                reviewCount: review.reviewCount,
                score: review.score,
                comment: review.comment
            )
        }
        self._uiReviews = State(initialValue: parsedReviews)
    }
    
    // Computed filtering engine resolving selection indexes against ascending configuration specifications
    var filteredBindableReviewIndices: [Int] {
        if let selectedIndex = selectedReviewFilterIndex {
            // Ensure the selected index is still valid before returning it
            return uiReviews.indices.contains(selectedIndex) ? [selectedIndex] : []
        } else {
            return Array(uiReviews.indices)
        }
    }
    
    var body: some View {
        ScrollView {
            Heading(text: "編輯評論")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 10)
                .padding(.horizontal, 35)
            
            // --- Type Section ---
            HStack {
                SubHeading(text: "類型", isProminent: false)
                Spacer()
                Picker("", selection: $reviewType) {
                    ForEach(ReviewType.allCases, id: \.self) { type in
                        Text(type.getTitle()).tag(type)
                    }
                }
                .pickerStyle(.menu)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 35)
            
            // --- Name Section ---
            VStack(alignment: .leading, spacing: 5) {
                SubHeading(text: "名稱", isProminent: false)
                TextField("輸入名稱", text: $name)
                    .textFieldStyle(.roundedBorder)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 35)
            .padding(.bottom, 15)
            
            // --- ✅ Description / Comment TextEditor Area Section ---
            VStack(alignment: .leading, spacing: 5) {
                SubHeading(text: "簡介", isProminent: false)
                TextEditor(text: $targetComment)
                    .frame(height: 100)
                    .padding(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 35)
            .padding(.bottom, 20)
            
            // --- Attributes Header Section (Accordion Toggler) ---
            Button {
                withAnimation(.easeInOut) {
                    isAttributesExpanded.toggle()
                }
            } label: {
                HStack {
                    SubHeading(text: "屬性", isProminent: false)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isAttributesExpanded ? 90 : 0))
                        .foregroundStyle(.gray)
                }
                .padding(.horizontal, 35)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            // --- Expanded Attributes Form List ---
            if isAttributesExpanded {
                VStack(spacing: 15) {
                    ForEach($uiAttributes) { $row in
                        HStack(alignment: .top, spacing: 12) {
                            Button {
                                if let index = uiAttributes.firstIndex(where: { $0.id == row.id }) {
                                    uiAttributes.remove(at: index)
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                                    .padding(.top, 8)
                            }
                            
                            VStack(spacing: 8) {
                                Picker("", selection: $row.type) {
                                    ForEach(ReviewAttributeType.allCases, id: \.self) { type in
                                        Text(type.getTitle()).tag(type)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if row.type == .link {
                                    TextField("連結名稱 (如: 巴哈姆特)", text: $row.linkTitle)
                                        .textFieldStyle(.roundedBorder)
                                    TextField("網址", text: $row.linkURLString)
                                        .textFieldStyle(.roundedBorder)
                                        .keyboardType(.URL)
                                        .autocorrectionDisabled()
                                } else if row.type == .releaseDate {
                                    let dateBinding = Binding<Date>(
                                        get: { fromDateString(text: row.textValue) ?? Date() },
                                        set: { row.textValue = toDateString(date: $0) }
                                    )
                                    
                                    DatePicker("選擇日期", selection: dateBinding, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } else {
                                    TextField("輸入屬性內容", text: $row.textValue)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                        }
                        .padding(.horizontal, 35)
                        Divider().padding(.horizontal, 35)
                    }
                    
                    Button {
                        let allowed = reviewType.getAttributeTypes()
                        let fallbackType = allowed.first ?? .genre
                        uiAttributes.append(UIAttributeRow(type: fallbackType))
                    } label: {
                        Label("新增屬性", systemImage: "plus.circle.fill")
                            .font(.subheadline)
                    }
                    .padding(.top, 5)
                }
                .padding(.top, 10)
            }
            
            // --- "預定？" Reservation Switch Section ---
            HStack {
                SubHeading(text: "預定？", isProminent: false)
                Spacer()
                Toggle("", isOn: $isReserved)
                    .labelsHidden()
                    .disabled(!uiReviews.isEmpty)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 15)
            .padding(.horizontal, 35)
            
            Divider().padding(.horizontal, 35)
            
            // --- Reviews Header Listing & Chronological Sorting Section ---
            VStack {
                HStack {
                    Heading(text: "評論列表")
                        .font(.title2)
                    Spacer()
                    
                    if !uiReviews.isEmpty {
                        // Connected filter menu sorted in ascending chronological ordering configuration
                        Picker("篩選評論", selection: $selectedReviewFilterIndex) {
                            Text("--全部--").tag(Int?.none)
                            ForEach(0..<uiReviews.count, id: \.self) { reverseDisplayIdx in
                                let labelCount = reverseDisplayIdx + 1
                                let targetBackingIndex = (uiReviews.count - 1) - reverseDisplayIdx
                                Text("第\(labelCount)次評論").tag(Int?.some(targetBackingIndex))
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(.blue)
                    }
                }
                .padding(.horizontal, 35)
                .padding(.top, 15)
                
                // --- Isolated Element Form Editors Loop Layout ---
                if !uiReviews.isEmpty {
                    VStack(spacing: 25) {
                        ForEach(filteredBindableReviewIndices, id: \.self) { idx in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("編輯第 \(uiReviews[idx].reviewCount) 次閱覽")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    
                                    // Top Right Delete Review Button
                                    Button {
                                        withAnimation {
                                            let reviewIdToDelete = uiReviews[idx].id
                                            
                                            if let selectedIdx = selectedReviewFilterIndex, uiReviews[selectedIdx].id == reviewIdToDelete {
                                                selectedReviewFilterIndex = nil
                                            }
                                            
                                            uiReviews.remove(at: idx)
                                            
                                            if uiReviews.isEmpty {
                                                isReserved = true
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundStyle(.red)
                                            .font(.subheadline)
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                // 1. Date Field Picker Form
                                HStack {
                                    Text("觀賞日:")
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                    DatePicker("", selection: $uiReviews[idx].date, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                }
                                
                                // 2. Chronological Review Ordering Counter Form Stepper
                                HStack {
                                    Text("閱覽次數:")
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                    Stepper(value: $uiReviews[idx].reviewCount, in: 1...100) {
                                        Text("第 \(uiReviews[idx].reviewCount) 次")
                                            .font(.subheadline)
                                    }
                                }
                                
                                // 3. User Grading Precision Control Slider Tracker Module
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("評分:")
                                            .font(.subheadline)
                                            .foregroundStyle(.gray)
                                        Score(score: uiReviews[idx].score, showNumber: true)
                                    }
                                    Slider(value: $uiReviews[idx].score, in: 0...5, step: 0.1)
                                        .tint(.blue)
                                }
                                
                                // 4. Extended Text Area Editor Form
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("評論內容:")
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                    TextEditor(text: $uiReviews[idx].comment)
                                        .frame(minHeight: 100)
                                        .padding(4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                                        )
                                }
                            }
                            .padding(.all, 15)
                            .background(Color(.secondarySystemBackground).opacity(0.5))
                            .cornerRadius(12)
                            .padding(.horizontal, 35)
                        }
                    }
                    .padding(.top, 10)
                }
                
                // --- "新增評論" Add Review Button Trigger Module ---
                Button {
                    withAnimation {
                        // Dynamically determine the next viewing sequence incremental value
                        let nextCount = (uiReviews.map { $0.reviewCount }.max() ?? 0) + 1
                        
                        let newReviewRow = UIReviewRow(
                            id: UUID(), // Fresh local mapping identifier
                            date: Date(),
                            reviewCount: nextCount,
                            score: 0.0,
                            comment: ""
                        )
                        uiReviews.append(newReviewRow)
                        
                        // Automatically drop reservation flag state tracking triggers when active objects enter context
                        isReserved = false
                    }
                } label: {
                    Label("新增評論", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .bold()
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    validateAndSave()
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                }
            }
            
            // 1. Added explicit cancel button to step backward out of editing context safely
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    onDismiss(nil)
                }
            }
        }
        .alert("屬性配置錯誤", isPresented: $showAlert) {
            Button("確認", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // --- Business Logic & Data Transformation Engine ---
    private func validateAndSave() {
        let validTypes = reviewType.getAttributeTypes()
        let invalidEntries = uiAttributes.filter { !validTypes.contains($0.type) }
        
        if !invalidEntries.isEmpty {
            let names = Set(invalidEntries.map { $0.type.getTitle() }).joined(separator: "、")
            alertMessage = "當前選擇的類型「\(reviewType.getTitle())」不支援以下屬性：\(names)。請先修正或刪除不合規的欄位。"
            showAlert = true
            return
        }
        
        target.name = name
        target.description = targetComment.isEmpty ? nil : targetComment // ✅ Persist target top-level comment string field back to core tracking reference
        target.type = reviewType
        
        // Upper attributes data transformation processing
        var textCompressionMap: [ReviewAttributeType: [String]] = [:]
        var linkCompressionMap: [String: String] = [:]
        
        for row in uiAttributes {
            if row.type == .link {
                if !row.linkTitle.isEmpty && !row.linkURLString.isEmpty {
                    linkCompressionMap[row.linkTitle] = row.linkURLString
                }
            } else {
                if !row.textValue.isEmpty {
                    textCompressionMap[row.type, default: []].append(row.textValue)
                }
            }
        }
        
        var finalizedAttributes: [ReviewAttribute] = []
        for (type, valueArray) in textCompressionMap {
            let compressedAttr = ReviewAttributeValue(type)
            compressedAttr.values = valueArray
            finalizedAttributes.append(compressedAttr)
        }
        if !linkCompressionMap.isEmpty {
            let compressedLinks = ReviewAttributeKeyValue(.link)
            compressedLinks.values = linkCompressionMap
            finalizedAttributes.append(compressedLinks)
        }
        target.attributes = finalizedAttributes
        
        // --- Reviews Data Sync Module ---
        // 1. Remove reviews deleted on UI from the core reference tracking instance
        target.reviews.removeAll { backingReview in
            !uiReviews.contains(where: { $0.id == backingReview.id })
        }
        
        // 2. Loop through UI state array to update or append values to target.reviews
        for uiReview in uiReviews {
            if let targetClassInstance = target.reviews.first(where: { $0.id == uiReview.id }) {
                // Update properties on an existing tracking review
                targetClassInstance.watched = uiReview.date
                targetClassInstance.reviewCount = uiReview.reviewCount
                targetClassInstance.score = uiReview.score
                targetClassInstance.comment = uiReview.comment
            } else {
                // Instantiate a concrete storage structural reference for newly created elements
                let newCoreReviewInstance = Review(
                    score: uiReview.score,
                    comment: uiReview.comment,
                    created: Date(),
                    watched: uiReview.date,
                    count: uiReview.reviewCount
                )
                target.reviews.append(newCoreReviewInstance)
            }
        }
        
        print("Save Operation Completed Successfully!")
        
        onDismiss(target)
    }
}

//#Preview {
//    EditPage(mockTarget)
//}
