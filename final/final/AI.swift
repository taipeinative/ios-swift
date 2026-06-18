import Foundation
import FoundationModels
import SwiftUI

enum AIInsightMood: String, CaseIterable, Codable, Identifiable {
    case positive = "正面"
    case neutral = "普通"
    case negative = "負面"
    case mixed = "混合"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .positive: return "sun.max.fill"
        case .neutral: return "cloud.fill"
        case .negative: return "cloud.rain.fill"
        case .mixed: return "cloud.sun.fill"
        }
    }

    var tint: Color {
        switch self {
        case .positive: return .orange
        case .neutral: return .blue
        case .negative: return .gray
        case .mixed: return .purple
        }
    }
}

enum AIInsightSuggestedType: String, CaseIterable, Codable, Identifiable {
    case book = "書籍"
    case drama = "戲劇"
    case location = "地點"
    case movie = "電影"
    case music = "音樂"
    case other = "其他"

    var id: String { rawValue }

    var targetType: TargetType {
        switch self {
        case .book: return .book
        case .drama: return .drama
        case .location: return .location
        case .movie: return .movie
        case .music: return .music
        case .other: return .other
        }
    }
}

struct AIUserAnalysis: Codable, Equatable {
    var recentReviewSummary: String
    var inferredMood: AIInsightMood
    var suggestedType: AIInsightSuggestedType

    static let placeholder = AIUserAnalysis(
        recentReviewSummary: "累積更多評論後，AI 會在這裡整理近期的感受與探索方向。",
        inferredMood: .neutral,
        suggestedType: .other
    )
}

enum AIInsightService {
    private static let maxRecentReviews = 6
    private static let maxCommentLength = 180
    private static let maxDescriptionLength = 80
    private static let maxAttributeCount = 3
    private static let maxAttributeValueLength = 40

    enum AnalysisError: LocalizedError {
        case noRecentReviews
        case modelUnavailable(String)
        case invalidResponse(String)

        var errorDescription: String? {
            switch self {
            case .noRecentReviews:
                return "尚無最近評論可供分析。"
            case .modelUnavailable(let reason):
                return reason
            case .invalidResponse(let response):
                return "模型沒有回傳可解析的 JSON：\(response)"
            }
        }
    }

    @MainActor
    static func recentReviewsJSON(from reviews: [Review]) throws -> String {
        let recentReviews = Array(reviews.prefix(maxRecentReviews))
        guard !recentReviews.isEmpty else { throw AnalysisError.noRecentReviews }

        let payload = AIInsightPayload(
            generatedAt: ISO8601DateFormatter().string(from: .now),
            allowedMoods: AIInsightMood.allCases.map(\.rawValue),
            allowedTargetTypes: AIInsightSuggestedType.allCases.map(\.rawValue),
            recentReviews: recentReviews.map {
                AIInsightSerializedReview(
                    review: $0,
                    maxCommentLength: maxCommentLength,
                    maxDescriptionLength: maxDescriptionLength,
                    maxAttributeCount: maxAttributeCount,
                    maxAttributeValueLength: maxAttributeValueLength
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(payload)
        return String(decoding: data, as: UTF8.self)
    }

    @available(iOS 26.0, *)
    static func analyzeRecentReviews(json: String) async throws -> AIUserAnalysis {
        let model = SystemLanguageModel.default
        guard case .available = model.availability else {
            throw AnalysisError.modelUnavailable(unavailableMessage(for: model.availability))
        }

        let session = LanguageModelSession(
            model: model,
            instructions: """
            你是評論日誌 App 的本機洞察分析器。你只能根據使用者提供的 JSON 資料分析，不可以捏造外部資料。

            你必須嚴格回傳純 JSON，不能加入 Markdown、註解、說明文字或程式碼區塊。
            你必須只回傳以下三個欄位：
            {
              "recentReviewSummary": "80字內的繁體中文總結",
              "inferredMood": "正面 或 普通 或 負面 或 混合",
              "suggestedType": "書籍 或 戲劇 或 地點 或 電影 或 音樂"
            }

            欄位規則：
            - recentReviewSummary 必須是台灣繁體中文，最多 50 個中文字。
            - inferredMood 只能是：正面、普通、負面、混合。
            - suggestedType 只能是：書籍、戲劇、地點、電影、音樂。
            - suggestedType 應該選擇使用者近期較少涉略、但可能值得拓展的分類。
            """
        )

        let response = try await session.respond(
            to: prompt(for: json),
            options: GenerationOptions(temperature: 0.35, maximumResponseTokens: 220)
        )

        return try decodeAnalysis(from: response.content)
    }

    @available(iOS 26.0, *)
    static func prompt(for json: String) -> String {
        """
        請分析以下 JSON。再次提醒：你只能回傳純 JSON，不可回傳 Markdown。

        \(json)
        """
    }

    static func decodeAnalysis(from response: String) throws -> AIUserAnalysis {
        let jsonString = response.trimmingCharacters(in: .whitespacesAndNewlines)
        let extracted = extractJSONObject(from: jsonString) ?? jsonString

        guard let data = extracted.data(using: .utf8),
              let analysis = try? JSONDecoder().decode(AIUserAnalysis.self, from: data) else {
            throw AnalysisError.invalidResponse(response)
        }

        return AIUserAnalysis(
            recentReviewSummary: String(analysis.recentReviewSummary.prefix(50)),
            inferredMood: analysis.inferredMood,
            suggestedType: analysis.suggestedType
        )
    }

    private static func extractJSONObject(from string: String) -> String? {
        guard let start = string.firstIndex(of: "{"),
              let end = string.lastIndex(of: "}"),
              start <= end else {
            return nil
        }

        return String(string[start...end])
    }

    @available(iOS 26.0, *)
    private static func unavailableMessage(for availability: SystemLanguageModel.Availability) -> String {
        guard case let .unavailable(reason) = availability else {
            return "Foundation Models 目前尚未準備好。"
        }

        switch reason {
        case .deviceNotEligible:
            return "此裝置不支援 Apple Intelligence。"
        case .appleIntelligenceNotEnabled:
            return "尚未啟用 Apple Intelligence。"
        case .modelNotReady:
            return "模型尚未下載或仍在準備中。"
        @unknown default:
            return "Foundation Models 目前不可用。"
        }
    }
}

@available(iOS 26.0, *)
struct AIInsightPreview: View {
    @State private var inputJSON = Self.sampleJSON
    @State private var response = "按下重新分析後，這裡會顯示 Foundation Models 回傳的 JSON 分析。"
    @State private var isAnalyzing = false

    private let colors = AppColors.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("最近評論 JSON")
                            .font(.headline)

                        TextField("JSON", text: $inputJSON, axis: .vertical)
                            .lineLimit(8...16)
                            .font(.caption.monospaced())
                            .padding(14)
                            .background(colors.secondaryGroupedSurface, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    Button {
                        analyze()
                    } label: {
                        if isAnalyzing {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Label("重新分析", systemImage: "arrow.clockwise.sparkle")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isAnalyzing)

                    VStack(alignment: .leading, spacing: 10) {
                        Label("模型回覆", systemImage: "sparkles")
                            .font(.headline)

                        Text(response)
                            .font(.body.monospaced())
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(18)
                    .background(colors.secondaryGroupedSurface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .padding(20)
            }
            .background(colors.primarySurface)
            .navigationTitle("AI 洞察測試")
        }
    }

    private func analyze() {
        isAnalyzing = true
        response = "正在分析..."

        Task {
            defer { isAnalyzing = false }

            do {
                let analysis = try await AIInsightService.analyzeRecentReviews(json: inputJSON)
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
                let data = try encoder.encode(analysis)
                response = String(decoding: data, as: UTF8.self)
            } catch {
                response = error.localizedDescription
            }
        }
    }

    private static let sampleJSON = """
    {
      "allowedMoods": ["正面", "普通", "負面", "混合"],
      "allowedTargetTypes": ["書籍", "戲劇", "地點", "電影", "音樂"],
      "recentReviews": [
        {
          "comment": "節奏很溫柔，雖然不是每一段都驚喜，但看完心情有被安放。",
          "score": 4.2,
          "target": {
            "name": "午後小旅行",
            "type": "電影"
          }
        }
      ]
    }
    """
}

private struct AIInsightPayload: Encodable {
    let generatedAt: String
    let allowedMoods: [String]
    let allowedTargetTypes: [String]
    let recentReviews: [AIInsightSerializedReview]
}

private struct AIInsightSerializedReview: Encodable {
    let actionDate: String
    let score: Double
    let comment: String
    let reviewCount: Int
    let photoCount: Int
    let target: AIInsightSerializedTarget?

    @MainActor
    init(
        review: Review,
        maxCommentLength: Int,
        maxDescriptionLength: Int,
        maxAttributeCount: Int,
        maxAttributeValueLength: Int
    ) {
        actionDate = Self.formatter.string(from: review.watched)
        score = review.score
        comment = review.comment.aiTrimmed(maxLength: maxCommentLength)
        reviewCount = review.reviewCount
        photoCount = review.photos.count
        target = review.target.map {
            AIInsightSerializedTarget(
                target: $0,
                maxDescriptionLength: maxDescriptionLength,
                maxAttributeCount: maxAttributeCount,
                maxAttributeValueLength: maxAttributeValueLength
            )
        }
    }

    private static let formatter = ISO8601DateFormatter()
}

private struct AIInsightSerializedTarget: Encodable {
    let id: String
    let name: String
    let type: String
    let summary: String
    let description: String?
    let attributes: [AIInsightSerializedAttribute]

    @MainActor
    init(
        target: Target,
        maxDescriptionLength: Int,
        maxAttributeCount: Int,
        maxAttributeValueLength: Int
    ) {
        id = target.id.uuidString
        name = target.name
        type = target.type.title
        summary = target.summaryText.aiTrimmed(maxLength: maxAttributeValueLength)
        description = target.descriptions?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty?
            .aiTrimmed(maxLength: maxDescriptionLength)
        attributes = Array(target.attributes.prefix(maxAttributeCount)).map {
            AIInsightSerializedAttribute(attribute: $0, maxValueLength: maxAttributeValueLength)
        }
    }
}

private struct AIInsightSerializedAttribute: Encodable {
    let type: String
    let value: String
    let secondaryValue: String?

    @MainActor
    init(attribute: TargetAttributeData, maxValueLength: Int) {
        type = attribute.type.title
        value = attribute.displayValue.aiTrimmed(maxLength: maxValueLength)
        secondaryValue = attribute.secondaryValue?.nilIfEmpty?.aiTrimmed(maxLength: maxValueLength)
    }
}

private extension String {
    func aiTrimmed(maxLength: Int) -> String {
        let normalized = replacingOccurrences(of: "\n\n", with: "\n")
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\t", with: " ")
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard normalized.count > maxLength else { return normalized }
        return String(normalized.prefix(maxLength)) + "…"
    }
}
