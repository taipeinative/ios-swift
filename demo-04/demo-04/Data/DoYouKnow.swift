import Foundation

struct DoYouKnow: Identifiable {
    let id = UUID()
    let question: String
    let keyword: String
    let answer: String
    let answerURL: String
}

let DoYouKnowData = [
    DoYouKnow(question: "哪一種塑膠製的裝飾物常見於壽司或刺身拼盤中，用來分隔食物與美化擺盤？", keyword: "哪一種塑膠製的裝飾物", answer: "山形葉", answerURL: "https://zh.wikipedia.org/zh-tw/山形葉"),
    DoYouKnow(question: "哪種電屬性寶可夢由西田敦子創作，並在動畫中被設定為小智最初獲得的寶可夢和旅途上的夥伴？", keyword: "哪種電屬性寶可夢", answer: "皮卡丘", answerURL: "https://zh.wikipedia.org/zh-tw/皮卡丘"),
    DoYouKnow(question: "當肛門無法正常排便時，可以在結腸上進行什麼手術來替代排便功能？", keyword: "什麼手術", answer: "結腸造口術", answerURL: "https://zh.wikipedia.org/zh-tw/結腸造口術"),
    DoYouKnow(question: "哪位春秋時期歷史人物是孔子的弟子兼女婿，相傳能聽懂鳥語？", keyword: "哪位春秋時期歷史人物", answer: "公冶長", answerURL: "https://zh.wikipedia.org/zh-tw/公冶长"),
    DoYouKnow(question: "哪一個國民小學健康操於2004年發行，融合了Rap和各國民謠，歌詞不斷出現人名Lucy？", keyword: "哪一個國民小學健康操", answer: "Safe Out運動身體好", answerURL: "https://zh.wikipedia.org/wiki/Safe_Out運動身體好"),
]
