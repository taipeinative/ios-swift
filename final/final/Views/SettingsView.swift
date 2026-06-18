import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @AppStorage("appTheme") private var appThemeRawValue = ThemeOption.system.rawValue
    @AppStorage(RatingStandard.key0To1) private var rating0To1 = ""
    @AppStorage(RatingStandard.key1To2) private var rating1To2 = ""
    @AppStorage(RatingStandard.key2To3) private var rating2To3 = ""
    @AppStorage(RatingStandard.key3To4) private var rating3To4 = ""
    @AppStorage(RatingStandard.key4To5) private var rating4To5 = ""
    @Query(sort: \Review.created, order: .forward) private var reviews: [Review]
    @Query(sort: \Target.name, order: .forward) private var targets: [Target]
    @Environment(\.modelContext) private var modelContext

    @State private var exportDocument: JSONTransferDocument?
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var importError: String?
    @State private var showImportAlert = false
    @AppStorage("isReplacingAppData") private var isReplacingAppData = false

    private var totalPoints: Int {
        reviews.reduce(into: 0) { partialResult, review in
            partialResult += review.comment.count
            partialResult += review.photos.count * 25
        }
    }

    private var currentLevel: Int {
        max(1, totalPoints / 100 + 1)
    }

    private var progress: CGFloat {
        CGFloat(totalPoints % 100) / 100
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                levelCard
                themeSection
                ratingStandardSection
                dataSection
            }
            .padding(20)
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "ReviewJournalBackup"
        ) { _ in }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
            Task { @MainActor in
                do {
                    let url = try result.get()
                    let data = try Data(contentsOf: url)
                    isReplacingAppData = true
                    await Task.yield()
                    try importPayload(data)
                    isReplacingAppData = false
                } catch {
                    isReplacingAppData = false
                    importError = Self.userFriendlyImportErrorMessage(for: error)
                    showImportAlert = true
                }
            }
        }
        .alert("匯入失敗", isPresented: $showImportAlert, presenting: importError) { _ in
            Button("知道了", role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }

    private var ratingStandardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("評分標準")
                    .font(.headline)

                Text("留白時會使用預設評語，這些文字會顯示在目標詳情的評論列表中。")
                    .font(.footnote)
                    .foregroundStyle(AppColors.shared.secondaryText)
            }

            HStack(alignment: .top, spacing: 14) {
                RatingScaleGuide()

                VStack(spacing: 10) {
                    RatingStandardField(text: $rating0To1, placeholder: RatingStandard.defaultTexts[0], accessibilityRange: "0 到 1 分")
                    RatingStandardField(text: $rating1To2, placeholder: RatingStandard.defaultTexts[1], accessibilityRange: "1 到 2 分")
                    RatingStandardField(text: $rating2To3, placeholder: RatingStandard.defaultTexts[2], accessibilityRange: "2 到 3 分")
                    RatingStandardField(text: $rating3To4, placeholder: RatingStandard.defaultTexts[3], accessibilityRange: "3 到 4 分")
                    RatingStandardField(text: $rating4To5, placeholder: RatingStandard.defaultTexts[4], accessibilityRange: "4 到 5 分")
                }
            }
        }
        .padding(20)
        .background(AppColors.shared.primarySurface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColors.shared.standardStroke)
        }
    }

    private var levelCard: some View {
        VStack(spacing: 16) {
            ZStack {
                HalfCircleProgressShape(progress: 1)
                    .stroke(AppColors.shared.prominentStroke, style: StrokeStyle(lineWidth: 16, lineCap: .round))

                HalfCircleProgressShape(progress: progress)
                    .stroke(AppColors.shared.levelProgress, style: StrokeStyle(lineWidth: 16, lineCap: .round))

                VStack(spacing: 6) {
                    Text("Lv. \(currentLevel)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))

                    Text("距離下一級還差 \(pointsToNextLevel) 分")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.shared.secondaryText)
                }
                .padding(.top, 44)
            }
            .frame(height: 180)

            Text("每 100 分升 1 級，評論字數每字 1 分，附圖每張 25 分。")
                .font(.footnote)
                .foregroundStyle(AppColors.shared.secondaryText)
        }
        .padding(20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("主題")
                .font(.headline)

            Picker("主題", selection: $appThemeRawValue) {
                ForEach(ThemeOption.allCases) { theme in
                    Text(theme.title).tag(theme.rawValue)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(20)
        .background(AppColors.shared.primarySurface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColors.shared.standardStroke)
        }
    }

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("資料管理")
                .font(.headline)

            Button("匯出紀錄") {
                let payload = ExportPayload(
                    targets: targets.map { $0.exportSnapshot },
                    reviews: reviews.compactMap { $0.exportSnapshot }
                )
                if let data = try? JSONEncoder().encode(payload) {
                    exportDocument = JSONTransferDocument(data: data)
                    isExporting = true
                }
            }
            .buttonStyle(.borderedProminent)

            Button("匯入紀錄（覆蓋目前資料）") {
                isImporting = true
            }
            .buttonStyle(.bordered)

            Text("匯入時會清空目前所有目標與評論，再以備份檔內容重建。")
                .font(.footnote)
                .foregroundStyle(AppColors.shared.secondaryText)
        }
        .padding(20)
        .background(AppColors.shared.primarySurface, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppColors.shared.standardStroke)
        }
    }

    private var pointsToNextLevel: Int {
        let remainder = totalPoints % 100
        return remainder == 0 ? 100 : 100 - remainder
    }

    private func importPayload(_ data: Data) throws {
        let payload = try JSONDecoder().decode(ExportPayload.self, from: data)
        let reviewsToDelete = Array(reviews)
        let targetsToDelete = Array(targets)

        for review in reviewsToDelete {
            modelContext.delete(review)
        }

        for target in targetsToDelete {
            modelContext.delete(target)
        }

        try modelContext.save()

        var targetMap: [UUID: Target] = [:]
        for snapshot in payload.targets {
            let target = Target(
                id: snapshot.id,
                name: snapshot.name,
                type: snapshot.type,
                attributes: snapshot.attributes,
                description: snapshot.descriptions,
                photos: snapshot.photos
            )
            modelContext.insert(target)
            targetMap[snapshot.id] = target
        }

        for snapshot in payload.reviews {
            guard let target = targetMap[snapshot.targetID] else { continue }
            let review = Review(
                id: snapshot.id,
                target: target,
                score: snapshot.score,
                comment: snapshot.comment,
                created: snapshot.created,
                watched: snapshot.watched,
                count: snapshot.reviewCount,
                photos: snapshot.photos
            )
            review.updated = snapshot.updated
            target.reviews.append(review)
            modelContext.insert(review)
        }

        try modelContext.save()
    }
}

private extension SettingsView {
    static func userFriendlyImportErrorMessage(for error: Error) -> String {
        if let decodingError = error as? DecodingError {
            return decodingErrorMessage(for: decodingError)
        }

        return error.localizedDescription
    }

    static func decodingErrorMessage(for error: DecodingError) -> String {
        switch error {
        case .keyNotFound(let key, let context):
            return "缺少必要欄位：\(jsonPath(from: context.codingPath + [key]))。"
        case .typeMismatch(let type, let context):
            return "欄位型別不正確：\(jsonPath(from: context.codingPath))，預期為 \(friendlyTypeName(type))。"
        case .valueNotFound(let type, let context):
            return "欄位內容為空：\(jsonPath(from: context.codingPath))，預期為 \(friendlyTypeName(type))。"
        case .dataCorrupted(let context):
            let path = jsonPath(from: context.codingPath)
            if path == "根物件" {
                return "JSON 內容損毀或格式不正確，無法讀取根物件。"
            }
            return "欄位資料格式不正確：\(path)。"
        @unknown default:
            return "JSON 格式不正確，無法完成匯入。"
        }
    }

    static func jsonPath(from codingPath: [CodingKey]) -> String {
        guard !codingPath.isEmpty else { return "根物件" }

        return codingPath.reduce(into: "") { partialResult, key in
            if let index = key.intValue {
                partialResult += "[\(index)]"
            } else {
                if !partialResult.isEmpty {
                    partialResult += "."
                }
                partialResult += key.stringValue
            }
        }
    }

    static func friendlyTypeName(_ type: Any.Type) -> String {
        switch String(describing: type) {
        case "String":
            return "文字"
        case "Int":
            return "整數"
        case "Double":
            return "小數"
        case "UUID":
            return "UUID"
        case "Date":
            return "日期"
        case "Array<PhotoAttachment>":
            return "圖片陣列"
        case "Array<TargetAttributeData>":
            return "屬性陣列"
        case "TargetType":
            return "目標分類"
        case "TargetAttributeType":
            return "屬性分類"
        default:
            return String(describing: type)
        }
    }
}

private struct RatingScaleGuide: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(AppColors.shared.standardStroke)
                .frame(width: 2, height: 250)
                .padding(.leading, 30)
                .padding(.top, 13)

            VStack(spacing: 29) {
                ForEach(0...5, id: \.self) { number in
                    Text("\(number)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.shared.secondaryText)
                        .frame(width: 22, alignment: .trailing)
                }
            }
        }
        .frame(width: 42, height: 276, alignment: .topLeading)
        .accessibilityHidden(true)
    }
}

private struct RatingStandardField: View {
    @Binding var text: String
    let placeholder: String
    let accessibilityRange: String

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .frame(height: 46)
            .background(AppColors.shared.secondaryGroupedSurface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppColors.shared.standardStroke)
            }
            .accessibilityLabel("\(accessibilityRange)的評語")
    }
}
