enum ReviewType: CaseIterable {
    case book
    case drama
    case location
    case movie
    case music
    case other
    
    func getAttributeTypes() -> [ReviewAttributeType] {
        switch self {
        case .book:
            return [
                ReviewAttributeType.author,
                ReviewAttributeType.genre,
                ReviewAttributeType.isbn,
                ReviewAttributeType.issn,
                ReviewAttributeType.publisher,
                ReviewAttributeType.releaseDate,
                ReviewAttributeType.translator,
                ReviewAttributeType.link
            ]
        case .drama:
            return [
                ReviewAttributeType.actor,
                ReviewAttributeType.director,
                ReviewAttributeType.genre,
                ReviewAttributeType.isan,
                ReviewAttributeType.producer,
                ReviewAttributeType.releaseDate,
                ReviewAttributeType.link
            ]
            
        case .location:
            return [
                ReviewAttributeType.address,
                ReviewAttributeType.genre,
                ReviewAttributeType.link
            ]
            
        case .movie:
            return [
                ReviewAttributeType.actor,
                ReviewAttributeType.director,
                ReviewAttributeType.genre,
                ReviewAttributeType.isan,
                ReviewAttributeType.producer,
                ReviewAttributeType.releaseDate,
                ReviewAttributeType.link
            ]
            
        case .music:
            return [
                ReviewAttributeType.artist,
                ReviewAttributeType.genre,
                ReviewAttributeType.isan,
                ReviewAttributeType.isrc,
                ReviewAttributeType.iswc,
                ReviewAttributeType.producer,
                ReviewAttributeType.releaseDate,
                ReviewAttributeType.link
            ]
            
        default:
            return ReviewAttributeType.allCases
        }
    }
    
    func getTitle() -> String {
        switch self {
        case .book:
            return "書籍"
        
        case .drama:
            return "戲劇"
            
        case .location:
            return "地點"
            
        case .movie:
            return "電影"
            
        case .music:
            return "音樂"
            
        default:
            return "其他"
        }
    }
}
