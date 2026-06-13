import Foundation

class Review: Identifiable {
    var id = UUID()
    var created: Date = Date()
    var updated: Date = Date()
    var watched: Date = Date()
    var score: Float = 3.0
    var comment: String = ""
    var reviewCount: Int = 1
    
    init(score: Float, comment: String, created: Date = Date(), watched: Date = Date(), count: Int = 1) {
        self.score = score
        self.comment = comment
        self.created = created
        self.updated = created
        self.watched = watched
        self.reviewCount = count
    }
}
