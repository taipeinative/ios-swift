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

func uiImage(from attachment: PhotoAttachment?) -> UIImage? {
    guard let attachment else { return nil }
    return UIImage(data: attachment.data)
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
