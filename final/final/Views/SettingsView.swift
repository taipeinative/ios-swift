import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @AppStorage("appTheme") private var appThemeRawValue = ThemeOption.system.rawValue
    @Query(sort: \Review.created, order: .forward) private var reviews: [Review]
    @Query(sort: \Target.name, order: .forward) private var targets: [Target]
    @Environment(\.modelContext) private var modelContext

    @State private var exportDocument: JSONTransferDocument?
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var importError: String?
    @State private var showImportAlert = false

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
            do {
                let url = try result.get()
                let data = try Data(contentsOf: url)
                try importPayload(data)
            } catch {
                importError = error.localizedDescription
                showImportAlert = true
            }
        }
        .alert("匯入失敗", isPresented: $showImportAlert, presenting: importError) { _ in
            Button("知道了", role: .cancel) {}
        } message: { message in
            Text(message)
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

        for review in reviews {
            modelContext.delete(review)
        }

        for target in targets {
            modelContext.delete(target)
        }

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
