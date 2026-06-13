enum ReviewAttributeType: CaseIterable {
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
}

extension ReviewAttributeType {
    func getTitle() -> String {
        switch self {
        case .actor: return "演員"
        case .address: return "地址"
        case .artist: return "藝人"
        case .author: return "作者"
        case .director: return "導演"
        case .genre: return "類型/流派"
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
}

