import ColorKit
import Foundation
import SwiftUI

func extractAverageColor(from image: UIImage) async -> Color? {
    guard let rgbImage = toRgbImage(from: image) else {
        return nil
    }

    guard let color = try? rgbImage.averageColor() else {
        return nil
    }
    
    return Color(uiColor: color)
}

func fromDateString(text: String) -> Date? {
    let strategy = Date.ParseStrategy(
        format: "\(year: .padded(4))-\(month: .twoDigits)-\(day: .twoDigits)",
        timeZone: TimeZone.current
    )
    return try? Date(text, strategy: strategy)
}

func getRatingName(score: Float) -> String {
    switch score {
    case ..<1:
        return "糟透了"
    case 1..<2:
        return "很糟糕"
        
    case 2..<3:
        return "不怎麼樣"
        
    case 3..<4:
        return "還不錯"
        
    case 4..<5:
        return "棒透了"
    
    default:
        return "評價"
    }
}

func toDateString(date: Date) -> String {
    let locale = Locale(identifier: "zh-TW")
    return date.formatted(
        .dateTime
            .year()
            .month(.wide)
            .day()
            .locale(locale)
    )
}

func toRgbImage(from image: UIImage) -> UIImage? {
    guard let cgImage = image.cgImage else { return nil }

    let width = cgImage.width
    let height = cgImage.height

    let colorSpace = CGColorSpaceCreateDeviceRGB()

    guard let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: width * 4,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        return nil
    }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    guard let rgbCGImage = context.makeImage() else {
        return nil
    }

    return UIImage(cgImage: rgbCGImage)
}

let mockTarget: ReviewTarget = {
    let target = ReviewTarget("關於我轉生變成史萊姆這檔事", type: .drama)
    target.image = UIImage(resource: .placeholder)
    target.attributes = [
        ReviewAttributeValue(.releaseDate, "2018-10-01"),
        ReviewAttributeKeyValue(.link, ["巴哈姆特": "https://acg.gamer.com.tw/acgDetail.php?s=94601"])
    ]
    target.description = "三上無趣的人生突然走到盡頭，轉生到另一個世界，成為魔物史萊姆。他召集了一群魔物，掀起了巨大風暴。"
    target.reviews = [
        Review(score: 4.7, comment: "趁著第四季上映來二刷。本作描述上班族三上悟在街上因隨機攻擊而死後，轉生到異世界成為史萊姆「利姆路」，憑藉著強大且越來越多的技能逐漸建設自己的理想國的故事。第一季是我目前最喜歡的章節，因為前期戰力分配合理，而且從小村落逐漸發展為城鎮的建國譚很和我的胃口。", created: fromDateString(text: "2026-05-29") ?? Date(), watched: fromDateString(text: "2026-05-05") ?? Date(), count: 2),
        Review(score: 4.5, comment: "蠻有趣的故事。第二季好像會變成開會番？", created: fromDateString(text: "2024-02-02") ?? Date(), watched: fromDateString(text: "2024-02-02") ?? Date(), count: 1)
    ]
    return target
}()

let mockTargets: [ReviewTarget] = [
    // TARGET 1: Video Game
    {
        let target = ReviewTarget("薩爾達傳說 王國之淚", type: .other)
        target.image = UIImage(resource: .placeholder)
        target.attributes = [
            ReviewAttributeValue(.releaseDate, "2023-05-12"),
            ReviewAttributeKeyValue(.link, [
                "任天堂官網": "https://www.nintendo.tw/totk/",
                "巴哈姆特哈啦板": "https://forum.gamer.com.tw/A.php?bsn=1647"
            ])
        ]
        target.description = "任天堂開發的開放世界動作冒險遊戲。玩家將再次扮演林克，在懸浮於空中的天空島嶼、廣大的海拉魯大地以及深邃的地底世界中冒險，運用全新的「究極手」與「餘料建造」能力拯救王國。"
        target.reviews = [
            Review(
                score: 5.0,
                comment: "2026年回頭三刷通關！這次挑戰了全神廟、全根部外加不升級血量的硬核玩法。拿到大師之劍跟打飛天巨龍的演出不管看幾次都會起雞皮疙瘩。究極手的自由度真的太恐怖了，隔了三年玩依然覺得是開放世界遊戲的里程碑，完全沒有落伍的感覺。",
                created: fromDateString(text: "2026-04-10") ?? Date(),
                watched: fromDateString(text: "2026-04-01") ?? Date(),
                count: 3
            ),
            Review(
                score: 4.9,
                comment: "開第二個存檔來二刷。主要想試試看不用常規打法，改用各種奇葩的左納烏科技組裝戰車去虐BOSS。地底世界的恐怖氛圍掌握得很好，跟空島的明亮形成強烈對比。真希望可以趕快出新DLC或者是下一代的消息啊！",
                created: fromDateString(text: "2024-08-20") ?? Date(),
                watched: fromDateString(text: "2024-08-01") ?? Date(),
                count: 2
            ),
            Review(
                score: 5.0,
                comment: "首發通關！毫無疑問的滿分神作。原本以為前作曠野之息已經是天花板了，沒想到王國之息還能靠著組裝系統把遊戲性再翻倍。餘料建造解決了前作武器容易壞的焦慮感，劇情給的史詩感和情感渲染也比前作更強烈，林克與薩爾達的羈絆太好哭了。",
                created: fromDateString(text: "2023-06-15") ?? Date(),
                watched: fromDateString(text: "2023-06-10") ?? Date(),
                count: 1
            )
        ]
        return target
    }(),
    
    // TARGET 2: Restaurant (Location)
    {
        let target = ReviewTarget("隱家拉麵 公館店", type: .location)
        target.image = UIImage(resource: .placeholder)
        target.attributes = [
            ReviewAttributeKeyValue(.link, ["Google Maps": "https://maps.app.goo.gl/inherent_mock_path"])
        ]
        target.description = "位於公館站附近的排隊名店，是公館商圈極具代表性的日式拉麵店。"
        target.reviews = [
            Review(
                score: 4.2,
                comment: "最近去吃了第4次，這次點了辛豚骨拉麵。辣度很夠，叉燒依舊保持高水準，軟嫩多汁。不過現在排隊人潮真的有點誇張，平日晚上也要等將近一個半小時，如果是肚子很餓的時候可能要考慮一下，但味道絕對還是公館前幾名。",
                created: fromDateString(text: "2026-05-14") ?? Date(),
                watched: fromDateString(text: "2026-05-14") ?? Date(),
                count: 4
            ),
            Review(
                score: 4.5,
                comment: "二訪帶朋友來吃。強烈推薦一定要加點豚骨沾麵，麵條超級Q彈，吸附濃郁的沾汁吃起來超級過癮！最後剩下的沾汁還可以請店家加清湯喝掉，冬天吃完一整碗真的超級幸福。肉盛（肉肉山）的份量依舊大到差點吃不完。",
                created: fromDateString(text: "2025-01-10") ?? Date(),
                watched: fromDateString(text: "2025-01-10") ?? Date(),
                count: 2
            )
        ]
        return target
    }(),
    
    // TARGET 3: Movie
    {
        let target = ReviewTarget("沙丘：第二部", type: .movie)
        target.image = UIImage(resource: .placeholder)
        target.attributes = [
            ReviewAttributeValue(.releaseDate, "2024-02-28"),
            ReviewAttributeKeyValue(.link, ["IMDb": "https://www.imdb.com/title/tt15234986/"])
        ]
        target.description = "丹尼·維勒納夫執導的科幻史詩鉅作。改編自法蘭克·赫伯特的同名小說，講述保羅·亞崔迪在厄拉科斯星球上與弗瑞曼人融合，並對毀滅他家族的陰謀者展開報復與聖戰的故事。"
        target.reviews = [
            Review(
                score: 4.9,
                comment: "買了新的家庭劇院音響，特地在家二刷4K藍光版。雖然少了IMAX大銀幕的震撼，但漢斯·季默的配樂一下，沙蟲奔馳的低音和聖戰的隆隆聲還是讓人頭皮發麻。保羅在全軍面前演講那段，提摩西的演技爆發力看幾次都覺得厲害，完美的科幻史詩。",
                created: fromDateString(text: "2025-11-05") ?? Date(),
                watched: fromDateString(text: "2025-11-01") ?? Date(),
                count: 2
            ),
            Review(
                score: 4.8,
                comment: "去大直美麗華看IMAX首映，這才是真正的電影藝術！畫面構圖、黃沙的顆粒感、還有菲德-羅薩在黑白星球角鬥場登場的視覺設計簡直絕了。第二部節奏比第一部快很多，沙蟲騎乘和最後的大戰動作戲誠意滿滿，絕對是這幾年影界最頂級的視覺饗宴。",
                created: fromDateString(text: "2024-03-02") ?? Date(),
                watched: fromDateString(text: "2024-02-29") ?? Date(),
                count: 1
            )
        ]
        return target
    }()
]
