import ColorKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import PhotosUI
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

@Observable
final class AppRouter {
    var selectedTab: AppTab = .home
}

enum AppTab: Hashable {
    case search
    case home
    case library
    case explore
}

final class AppColors {
    static let shared = AppColors()

    private init() {}

    let primaryText = Color.primary
    let secondaryText = Color.secondary
    let tertiaryText = Color(uiColor: .tertiaryLabel)
    let inverseText = Color.white
    let transparent = Color.clear

    let primarySurface = Color(uiColor: .systemBackground)
    let secondaryGroupedSurface = Color(uiColor: .secondarySystemGroupedBackground)
    let tertiaryGroupedSurface = Color(uiColor: .tertiarySystemGroupedBackground)

    let subtleFill = Color.secondary.opacity(0.07)
    let faintFill = Color.secondary.opacity(0.03)
    let defaultImageAverageFill = Color.secondary.opacity(0.15)
    let standardStroke = Color.secondary.opacity(0.12)
    let prominentStroke = Color.secondary.opacity(0.18)
    let cardShadow = Color.black.opacity(0.06)
    let dimOverlay = Color.black.opacity(0.65)
    let fullScreenBackdrop = Color.black

    let score = Color.orange
    let link = Color.blue
    let success = Color.green
    let destructive = Color.red
    let activeControlBackground = Color.primary
    let levelProgress = Color.accentColor
    let previewImageTextUIColor = UIColor.white

    func targetColor(for type: TargetType) -> Color {
        switch type {
        case .book: return .red
        case .drama: return .orange
        case .location: return .yellow
        case .movie: return .green
        case .music: return .blue
        case .other: return .purple
        }
    }

    func attributeListPalette(for colorScheme: ColorScheme) -> AttributeListPalette {
        switch colorScheme {
        case .dark:
            return AttributeListPalette(
                listBackground: secondaryGroupedSurface,
                cardBackground: tertiaryGroupedSurface,
                cardStroke: Color.white.opacity(0.08),
                iconTint: secondaryText
            )
        default:
            return AttributeListPalette(
                listBackground: secondaryGroupedSurface,
                cardBackground: subtleFill,
                cardStroke: Color.black.opacity(0.08),
                iconTint: secondaryText
            )
        }
    }
}

struct AttributeListPalette {
    let listBackground: Color
    let cardBackground: Color
    let cardStroke: Color
    let iconTint: Color

    static func colors(for colorScheme: ColorScheme) -> AttributeListPalette {
        AppColors.shared.attributeListPalette(for: colorScheme)
    }
}

struct MultilineInputField: View {
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(AppColors.shared.tertiaryText)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $text)
                .frame(minHeight: minHeight)
                .scrollContentBackground(.hidden)
                .autocorrectionDisabled()
        }
    }
}

enum ThemeOption: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "跟隨系統"
        case .light: return "淺色"
        case .dark: return "深色"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum ReviewCountComparison: String, CaseIterable, Identifiable {
    case lessOrEqual
    case equal
    case greaterOrEqual

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lessOrEqual: return "小於等於"
        case .equal: return "等於"
        case .greaterOrEqual: return "大於等於"
        }
    }
}

enum ReviewUpdatedRange: String, CaseIterable, Identifiable {
    case all
    case sevenDays
    case thirtyDays
    case oneYear
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "全部時間"
        case .sevenDays: return "7 天內"
        case .thirtyDays: return "30 天內"
        case .oneYear: return "1 年內"
        case .custom: return "自訂"
        }
    }
}

enum RatingStandard {
    static let key0To1 = "ratingStandard0To1"
    static let key1To2 = "ratingStandard1To2"
    static let key2To3 = "ratingStandard2To3"
    static let key3To4 = "ratingStandard3To4"
    static let key4To5 = "ratingStandard4To5"

    static let defaultTexts = [
        "糟透了",
        "不太喜歡",
        "普普通通",
        "很不錯",
        "棒透了"
    ]

    static func text(for score: Double, customTexts: [String]) -> String {
        let index = index(for: score)
        let customText = customTexts[safe: index]?.nilIfEmpty
        return customText ?? defaultTexts[index]
    }

    private static func index(for score: Double) -> Int {
        min(4, max(0, Int(score.rounded(.down))))
    }
}

@Observable
final class ReviewFilterState {
    var updatedRange: ReviewUpdatedRange = .all
    var targetType: TargetType? = nil
    var comparison: ReviewCountComparison = .greaterOrEqual
    var reviewCount: Int = 1
    var customStartDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    var customEndDate: Date = .now

    var hasReviewCountFilter: Bool {
        !(comparison == .greaterOrEqual && reviewCount == 1)
    }

    var activeFilterCount: Int {
        var count = 0
        if updatedRange != .all {
            count += 1
        }
        if targetType != nil {
            count += 1
        }
        if hasReviewCountFilter {
            count += 1
        }
        return count
    }

    func matches(_ review: Review) -> Bool {
        guard matchesDate(review.watched) else { return false }

        if let targetType, review.target?.type != targetType {
            return false
        }

        guard hasReviewCountFilter else {
            return true
        }

        switch comparison {
        case .lessOrEqual:
            return review.reviewCount <= reviewCount
        case .equal:
            return review.reviewCount == reviewCount
        case .greaterOrEqual:
            return review.reviewCount >= reviewCount
        }
    }

    private func matchesDate(_ date: Date, now: Date = .now) -> Bool {
        let calendar = Calendar.current

        switch updatedRange {
        case .all:
            return true
        case .sevenDays:
            return date >= (calendar.date(byAdding: .day, value: -7, to: now) ?? .distantPast)
        case .thirtyDays:
            return date >= (calendar.date(byAdding: .day, value: -30, to: now) ?? .distantPast)
        case .oneYear:
            return date >= (calendar.date(byAdding: .year, value: -1, to: now) ?? .distantPast)
        case .custom:
            let start = calendar.startOfDay(for: min(customStartDate, customEndDate))
            let endDay = calendar.startOfDay(for: max(customStartDate, customEndDate))
            let end = calendar.date(byAdding: .day, value: 1, to: endDay) ?? endDay
            return date >= start && date < end
        }
    }
}

@Observable
final class LibraryFilterState {
    var keyword: String = ""
    var reviewDateRange: ReviewUpdatedRange = .all
    var targetType: TargetType? = nil
    var comparison: ReviewCountComparison = .greaterOrEqual
    var reviewCount: Int = 1
    var customStartDate: Date = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    var customEndDate: Date = .now

    var normalizedKeyword: String {
        keyword.trimmingCharacters(in: .whitespacesAndNewlines).localizedLowercase
    }

    var hasKeywordFilter: Bool {
        !normalizedKeyword.isEmpty
    }

    var hasReviewCountFilter: Bool {
        !(comparison == .greaterOrEqual && reviewCount == 1)
    }

    var activeFilterCount: Int {
        var count = 0
        if reviewDateRange != .all {
            count += 1
        }
        if targetType != nil {
            count += 1
        }
        if hasReviewCountFilter {
            count += 1
        }
        return count
    }

    var activeConditionCount: Int {
        activeFilterCount + (hasKeywordFilter ? 1 : 0)
    }

    func matches(_ target: Target) -> Bool {
        guard matchesKeyword(target) else { return false }
        guard matchesReviewDateRange(target) else { return false }
        guard matchesTargetType(target) else { return false }
        return matchesReviewCount(target)
    }

    private func matchesKeyword(_ target: Target) -> Bool {
        guard hasKeywordFilter else { return true }
        return target.searchableText.contains(normalizedKeyword)
    }

    private func matchesTargetType(_ target: Target) -> Bool {
        guard let targetType else { return true }
        return target.type == targetType
    }

    private func matchesReviewCount(_ target: Target) -> Bool {
        guard hasReviewCountFilter else { return true }

        switch comparison {
        case .lessOrEqual:
            return target.reviews.count <= reviewCount
        case .equal:
            return target.reviews.count == reviewCount
        case .greaterOrEqual:
            return target.reviews.count >= reviewCount
        }
    }

    private func matchesReviewDateRange(_ target: Target, now: Date = .now) -> Bool {
        guard reviewDateRange != .all else { return true }
        return target.reviews.contains { review in
            matches(date: review.watched, now: now)
        }
    }

    private func matches(date: Date, now: Date) -> Bool {
        let calendar = Calendar.current

        switch reviewDateRange {
        case .all:
            return true
        case .sevenDays:
            return date >= (calendar.date(byAdding: .day, value: -7, to: now) ?? .distantPast)
        case .thirtyDays:
            return date >= (calendar.date(byAdding: .day, value: -30, to: now) ?? .distantPast)
        case .oneYear:
            return date >= (calendar.date(byAdding: .year, value: -1, to: now) ?? .distantPast)
        case .custom:
            let start = calendar.startOfDay(for: min(customStartDate, customEndDate))
            let endDay = calendar.startOfDay(for: max(customStartDate, customEndDate))
            let end = calendar.date(byAdding: .day, value: 1, to: endDay) ?? endDay
            return date >= start && date < end
        }
    }
}

struct ReviewSnapshot: Codable {
    var id: UUID
    var targetID: UUID
    var created: Date
    var updated: Date
    var watched: Date
    var score: Double
    var comment: String
    var reviewCount: Int
    var photos: [PhotoAttachment]
}

struct TargetSnapshot: Codable {
    var id: UUID
    var name: String
    var type: TargetType
    var attributes: [TargetAttributeData]
    var descriptions: String?
    var photos: [PhotoAttachment]
}

struct ExportPayload: Codable {
    var targets: [TargetSnapshot]
    var reviews: [ReviewSnapshot]
}

struct JSONTransferDocument: FileDocument {
    static let readableContentTypes: [UTType] = [.json]

    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

func extractAverageColor(from image: UIImage) async -> Color? {
    guard let cgImage = image.cgImage else {
        return nil
    }

    let ciImage = CIImage(cgImage: cgImage)
    let extent = ciImage.extent
    let filter = CIFilter.areaAverage()
    filter.inputImage = ciImage
    filter.extent = extent

    let context = CIContext(options: [.workingColorSpace: NSNull()])
    var bitmap = [UInt8](repeating: 0, count: 4)

    context.render(
        filter.outputImage ?? ciImage,
        toBitmap: &bitmap,
        rowBytes: 4,
        bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
        format: .RGBA8,
        colorSpace: nil
    )

    return Color(
        red: Double(bitmap[0]) / 255,
        green: Double(bitmap[1]) / 255,
        blue: Double(bitmap[2]) / 255
    )
}

func extractAverageColorColorKit(from image: UIImage) async -> Color? {
    guard let rgbImage = toRgbImageColorKit(from: image) else {
        return nil
    }

    guard let color = try? rgbImage.averageColor() else {
        return nil
    }

    return Color(uiColor: color)
}

func extractAverageColorColorKit(from attachment: PhotoAttachment?) async -> Color? {
    guard let image = await loadUIImage(from: attachment) else {
        return nil
    }

    return await extractAverageColorColorKit(from: image)
}

func toRgbImageColorKit(from image: UIImage) -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }

    let width = cgImage.width
    let height = cgImage.height
    let colorSpace = CGColorSpaceCreateDeviceRGB()

    guard let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width * 4,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        return nil
    }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    guard let rgbCGImage = context.makeImage() else {
        return nil
    }

    return UIImage(cgImage: rgbCGImage)
}

func uiImage(from attachment: PhotoAttachment?) -> UIImage? {
    guard let data = attachment?.data else { return nil }
    return UIImage(data: data)
}

func loadUIImage(from attachment: PhotoAttachment?) async -> UIImage? {
    if let image = uiImage(from: attachment) {
        return image
    }

    guard let url = attachment?.url else {
        return nil
    }

    var request = URLRequest(url: url)
    request.cachePolicy = .reloadIgnoringLocalCacheData

    guard let (data, response) = try? await URLSession.shared.data(for: request) else {
        return nil
    }

    if let httpResponse = response as? HTTPURLResponse,
       !(200..<300).contains(httpResponse.statusCode) {
        return nil
    }

    return UIImage(data: data)
}

func extractAverageColor(from attachment: PhotoAttachment?) async -> Color? {
    guard let image = await loadUIImage(from: attachment) else {
        return nil
    }

    return await extractAverageColor(from: image)
}

func loadPhotoAttachments(
    from items: [PhotosPickerItem],
    existing: [PhotoAttachment] = [],
    limit: Int = 5
) async -> [PhotoAttachment] {
    var attachments: [PhotoAttachment] = existing

    for item in items.prefix(limit) {
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            continue
        }
        if attachments.contains(where: { $0.data == data }) {
            continue
        }
        attachments.append(PhotoAttachment(data: data))
    }

    return Array(attachments.prefix(limit))
}

struct AttachmentImage: View {
    let attachment: PhotoAttachment?
    var contentMode: ContentMode = .fill
    var placeholderPadding: CGFloat = 0
    var refreshKey = ""

    var body: some View {
        Group {
            if let image = uiImage(from: attachment) {
                configuredImage(Image(uiImage: image))
            } else if let url = attachment?.url {
                RemoteAttachmentImage(
                    url: url,
                    contentMode: contentMode,
                    placeholderPadding: placeholderPadding,
                    refreshKey: refreshKey
                )
            } else {
                placeholder
            }
        }
    }

    @ViewBuilder
    private func configuredImage(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }

    private var placeholder: some View {
        Image(.placeholder)
            .resizable()
            .scaledToFit()
            .padding(placeholderPadding)
            .background(AppColors.shared.defaultImageAverageFill)
    }
}

private struct RemoteAttachmentImage: View {
    let url: URL
    let contentMode: ContentMode
    let placeholderPadding: CGFloat
    let refreshKey: String

    @State private var image: UIImage?
    @State private var didFail = false

    private var taskID: String {
        "\(url.absoluteString)-\(refreshKey)"
    }

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if didFail {
                placeholder
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task(id: taskID) {
            await loadImage()
        }
    }

    @MainActor
    private func loadImage() async {
        image = nil
        didFail = false

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              (response as? HTTPURLResponse).map({ (200..<300).contains($0.statusCode) }) ?? true,
              let loadedImage = UIImage(data: data) else {
            didFail = true
            return
        }

        image = loadedImage
    }

    private var placeholder: some View {
        Image(.placeholder)
            .resizable()
            .scaledToFit()
            .padding(placeholderPadding)
            .background(AppColors.shared.defaultImageAverageFill)
    }
}

extension DateFormatter {
    static let reviewDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_Hant_TW")
        formatter.dateStyle = .medium
        return formatter
    }()
}

extension TargetType {
    var color: Color {
        AppColors.shared.targetColor(for: self)
    }
}

extension Target {
    var primaryPhoto: PhotoAttachment? {
        photos.first
    }

    var summaryText: String {
        switch type {
        case .book:
            return firstAttributeText(for: .author) ?? "尚未填寫作者"
        case .music:
            return firstAttributeText(for: .artist) ?? "尚未填寫藝人"
        case .location:
            return firstAttributeText(for: .address) ?? "尚未填寫地址"
        case .movie, .drama:
            if let year = releaseYear {
                return "\(year) 年"
            }
            return "尚未填寫年份"
        case .other:
            return descriptions?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "尚未填寫描述"
        }
    }

    var releaseYear: Int? {
        guard let releaseDate = attributes.first(where: { $0.type == .releaseDate })?.dateValue else {
            return nil
        }
        return Calendar.current.component(.year, from: releaseDate)
    }

    func firstAttributeText(for type: TargetAttributeType) -> String? {
        attributes.first(where: { $0.type == type })?.displayValue.nilIfEmpty
    }

    var searchableText: String {
        let base = [name, descriptions ?? "", type.title]
        let attributeTexts = attributes.flatMap { [$0.type.title, $0.displayValue, $0.secondaryValue ?? ""] }
        return (base + attributeTexts).joined(separator: " ").localizedLowercase
    }
}

extension Review {
    var primaryPhoto: PhotoAttachment? {
        photos.first ?? target?.primaryPhoto
    }

    var exportSnapshot: ReviewSnapshot? {
        guard let targetID = target?.id else { return nil }
        return ReviewSnapshot(
            id: id,
            targetID: targetID,
            created: created,
            updated: updated,
            watched: watched,
            score: score,
            comment: comment,
            reviewCount: reviewCount,
            photos: photos
        )
    }

    var searchableText: String {
        [comment, target?.name ?? "", target?.searchableText ?? ""]
            .joined(separator: " ")
            .localizedLowercase
    }
}

extension Target {
    var exportSnapshot: TargetSnapshot {
        TargetSnapshot(
            id: id,
            name: name,
            type: type,
            attributes: attributes,
            descriptions: descriptions,
            photos: photos
        )
    }
}

extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct HalfCircleProgressShape: Shape {
    var progress: CGFloat

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width / 2, rect.height)
        let center = CGPoint(x: rect.midX, y: rect.maxY)

        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(180 + Double(progress) * 180),
            clockwise: false
        )
        return path
    }
}
