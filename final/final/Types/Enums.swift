import Foundation

enum TargetType: CaseIterable, Codable, Hashable, Sendable {
    case book
    case drama
    case location
    case movie
    case music
    case other
    
    func getAttributeTypes() -> [TargetAttributeType] {
        switch self {
        case .book:
            return [
                TargetAttributeType.author,
                TargetAttributeType.genre,
                TargetAttributeType.isbn,
                TargetAttributeType.issn,
                TargetAttributeType.publisher,
                TargetAttributeType.releaseDate,
                TargetAttributeType.translator,
                TargetAttributeType.link
            ]
        case .drama:
            return [
                TargetAttributeType.actor,
                TargetAttributeType.director,
                TargetAttributeType.genre,
                TargetAttributeType.isan,
                TargetAttributeType.producer,
                TargetAttributeType.releaseDate,
                TargetAttributeType.link
            ]
            
        case .location:
            return [
                TargetAttributeType.address,
                TargetAttributeType.genre,
                TargetAttributeType.link
            ]
            
        case .movie:
            return [
                TargetAttributeType.actor,
                TargetAttributeType.director,
                TargetAttributeType.genre,
                TargetAttributeType.isan,
                TargetAttributeType.producer,
                TargetAttributeType.releaseDate,
                TargetAttributeType.link
            ]
            
        case .music:
            return [
                TargetAttributeType.artist,
                TargetAttributeType.genre,
                TargetAttributeType.isan,
                TargetAttributeType.isrc,
                TargetAttributeType.iswc,
                TargetAttributeType.producer,
                TargetAttributeType.releaseDate,
                TargetAttributeType.link
            ]
            
        default:
            return TargetAttributeType.allCases
        }
    }
    
    var title: String {
        switch self {
        case .book: return "書籍"
        case .drama: return "戲劇"
        case .location: return "地點"
        case .movie: return "電影"
        case .music: return "音樂"
        default: return "其他"
        }
    }
    var actionDateTitle: String {
        switch self {
        case .movie, .drama:
            return "觀看日期"
        case .music:
            return "聆聽日期"
        case .book:
            return "閱讀日期"
        case .location:
            return "造訪日期"
        case .other:
            return "體驗日期"
        }
    }
}

enum AttributeInputKind: Sendable {
    case text
    case date
    case link
}

enum TargetAttributeType: CaseIterable, Codable, Hashable, Sendable {
    case actor
    case address
    case artist
    case author
    case director
    case genre
    case producer
    case publisher
    case releaseDate
    case translator
    case isan           // International Standard Audiovisual Number
    case isbn           // International Standard Book Number
    case isrc           // International Standard Recording Code
    case issn           // International Standard Serial Number
    case iswc           // International Standard Musical Work Code
    case link

    var title: String {
        switch self {
        case .actor: return "演員"
        case .address: return "地址"
        case .artist: return "藝人"
        case .author: return "作者"
        case .director: return "導演"
        case .genre: return "類型"
        case .producer: return "製作人"
        case .publisher: return "出版商"
        case .releaseDate: return "發行日期"
        case .translator: return "翻譯者"
        case .isan: return "ISAN 碼"
        case .isbn: return "ISBN 碼"
        case .isrc: return "ISRC 碼"
        case .issn: return "ISSN 碼"
        case .iswc: return "ISWC 碼"
        case .link: return "相關連結"
        }
    }

    var inputKind: AttributeInputKind {
        switch self {
        case .releaseDate:
            return .date
        case .link:
            return .link
        default:
            return .text
        }
    }
}
