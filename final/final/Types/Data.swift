import Foundation
import SwiftData

@Model
class Review: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var target: Target?
    var created: Date = Date()
    var updated: Date = Date()
    var watched: Date = Date()
    var score: Double = 3.0
    var comment: String = ""
    var reviewCount: Int = 1
    var photos: [PhotoAttachment] = []

    init(
        id: UUID = UUID(),
        target: Target? = nil,
        score: Double,
        comment: String,
        created: Date = Date(),
        watched: Date = Date(),
        count: Int = 1,
        photos: [PhotoAttachment] = []
    ) {
        self.id = id
        self.target = target
        self.score = score
        self.comment = comment
        self.created = created
        self.updated = created
        self.watched = watched
        self.reviewCount = count
        self.photos = photos
    }
}

@Model
class Target: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var type: TargetType
    var attributes: [TargetAttributeData] = []
    var descriptions: String? = nil
    var reviews: [Review] = []
    var photos: [PhotoAttachment] = []

    init(
        id: UUID = UUID(),
        name: String,
        type: TargetType,
        attributes: [TargetAttributeData] = [],
        description: String? = nil,
        photos: [PhotoAttachment] = []
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.attributes = attributes
        self.descriptions = description
        self.photos = photos
    }
}

enum PhotoAttachmentKind: String, Codable, Hashable {
    case local
    case remote
}

struct PhotoAttachment: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var kind: PhotoAttachmentKind = .local
    var data: Data?
    var urlString: String?

    init(id: UUID = UUID(), data: Data) {
        self.id = id
        self.kind = .local
        self.data = data
        self.urlString = nil
    }

    init(id: UUID = UUID(), urlString: String) {
        self.id = id
        self.kind = .remote
        self.data = nil
        self.urlString = urlString
    }

    var url: URL? {
        guard let urlString = urlString?.nilIfEmpty else { return nil }
        if let url = URL(string: urlString), url.scheme != nil {
            return url
        }
        return URL(string: "https://\(urlString)")
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case kind
        case data
        case urlString
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        data = try container.decodeIfPresent(Data.self, forKey: .data)
        urlString = try container.decodeIfPresent(String.self, forKey: .urlString)
        kind = try container.decodeIfPresent(PhotoAttachmentKind.self, forKey: .kind) ?? (data == nil ? .remote : .local)
    }
}

struct TargetAttributeData: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var type: TargetAttributeType
    var textValue: String? = nil
    var secondaryValue: String? = nil
    var dateValue: Date? = nil

    init(
        id: UUID = UUID(),
        type: TargetAttributeType,
        textValue: String? = nil,
        secondaryValue: String? = nil,
        dateValue: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.textValue = textValue
        self.secondaryValue = secondaryValue
        self.dateValue = dateValue
    }

    var displayValue: String {
        switch type.inputKind {
        case .text:
            return textValue ?? ""
        case .date:
            guard let dateValue else { return "" }
            return DateFormatter.reviewDate.string(from: dateValue)
        case .link:
            return textValue ?? ""
        }
    }

    var formattedValue: String {
        switch type.inputKind {
        case .text:
            return textValue ?? "未填寫"
        case .date:
            guard let dateValue else { return "未填寫" }
            return DateFormatter.reviewDate.string(from: dateValue)
        case .link:
            let label = textValue ?? "未命名連結"
            let url = secondaryValue ?? ""
            return url.isEmpty ? label : "\(label)\n\(url)"
        }
    }
}

struct AttributeDraft: Identifiable, Hashable {
    let id: UUID
    var type: TargetAttributeType
    var textValue: String
    var secondaryText: String
    var dateValue: Date

    init(id: UUID = UUID(), type: TargetAttributeType, textValue: String = "", secondaryText: String = "", dateValue: Date = .now) {
        self.id = id
        self.type = type
        self.textValue = textValue
        self.secondaryText = secondaryText
        self.dateValue = dateValue
    }

    init(data: TargetAttributeData) {
        id = data.id
        type = data.type
        textValue = data.displayValue
        secondaryText = data.secondaryValue ?? ""
        dateValue = data.dateValue ?? .now
    }

    var data: TargetAttributeData {
        switch type.inputKind {
        case .date:
            return TargetAttributeData(id: id, type: type, textValue: nil, secondaryValue: nil, dateValue: dateValue)
        case .link:
            return TargetAttributeData(
                id: id,
                type: type,
                textValue: textValue.nilIfEmpty,
                secondaryValue: secondaryText.nilIfEmpty,
                dateValue: nil
            )
        case .text:
            return TargetAttributeData(id: id, type: type, textValue: textValue.nilIfEmpty, secondaryValue: nil, dateValue: nil)
        }
    }

    func duplicated() -> AttributeDraft {
        AttributeDraft(
            id: UUID(),
            type: type,
            textValue: textValue,
            secondaryText: secondaryText,
            dateValue: dateValue
        )
    }
}
