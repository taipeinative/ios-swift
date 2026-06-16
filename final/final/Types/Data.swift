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

struct PhotoAttachment: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var data: Data
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
