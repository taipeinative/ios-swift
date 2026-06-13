import Foundation
import SwiftUI

class ReviewTarget: Identifiable {
    var id = UUID()
    var name: String
    var type: ReviewType
    var attributes: [ReviewAttribute] = []
    var description: String? = nil
    var reviews: [Review] = []
    var image: UIImage = UIImage(resource: .placeholder)
    
    init(_ name: String, type: ReviewType) {
        self.name = name
        self.type = type
    }
    
    init (name: String, type: ReviewType, attributes: [ReviewAttribute] = [], reviews: [Review] = [])
    {
        self.name = name
        self.type = type
        self.attributes = attributes
        self.reviews = reviews
    }
    
    func isReserved() -> Bool {
        return reviews.count == 0
    }
    
    func getReleaseDate() -> Date {
        var releaseDate = fromDateString(text: "0001-01-01") ?? Date()
        
        if let attribute = attributes.first(where: { $0.type == .releaseDate }) as? ReviewAttributeValue,
           let dateString = attribute.values.first {
            
            if let parsedDate = fromDateString(text: dateString) {
                releaseDate = parsedDate
            }
        }
        
        return releaseDate
    }
    
    func getURLs() -> [String: URL?] {
        var urlMap: [String: URL?] = [:]
        
        for attribute in attributes {
            if let keyValueAttribute = attribute as? ReviewAttributeKeyValue {
                for (key, urlString) in keyValueAttribute.values {
                    let url = URL(string: urlString)
                    urlMap[key] = url
                }
            }
        }
        
        return urlMap
    }
}

extension ReviewTarget: Hashable, Equatable {
    
    // Equatable conformance: Two targets are considered equal if their stable unique IDs match
    static func == (lhs: ReviewTarget, rhs: ReviewTarget) -> Bool {
        lhs.id == rhs.id
    }
    
    // Hashable conformance: Feed the stable unique ID into the hasher pool
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
