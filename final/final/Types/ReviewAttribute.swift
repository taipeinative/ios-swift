import Foundation

class ReviewAttribute: Identifiable {
    var id = UUID()
    var type: ReviewAttributeType
    
    init(_ type: ReviewAttributeType) {
        self.type = type
    }
}

class ReviewAttributeValue: ReviewAttribute {
    var values: [String] = []
    
    override init(_ type: ReviewAttributeType) {
        super.init(type)
    }
    
    init(_ type: ReviewAttributeType, _ value: String) {
        self.values = [value]
        super.init(type)
    }
    
    init(_ type: ReviewAttributeType, _ values: [String]) {
        self.values = values
        super.init(type)
    }
}

class ReviewAttributeKeyValue: ReviewAttribute {
    var values: [String: String] = [:]
    
    override init(_ type: ReviewAttributeType) {
        super.init(type)
    }
    
    init(_ type: ReviewAttributeType, _ values: [String: String])
    {
        self.values = values
        super.init(type)
    }
}
