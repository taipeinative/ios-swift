import Foundation

struct OnThisDay: Identifiable {
    let id = UUID()
    let year: Int
    let title: String
    let text: String
    let imageURL: String
}

let OnThisDayData = [
    OnThisDay(year: 1481, title: "穆罕默德二世逝世", text: "穆罕默德二世（1432-1481）是鄂圖曼帝國蘇丹，又被尊稱為「征服者」蘇丹穆罕默德，於年僅21歲的時候，即指揮鄂圖曼帝國大軍攻陷君士坦丁堡，消滅了東羅馬帝國。", imageURL: "https://upload.wikimedia.org/wikipedia/commons/6/6e/Bellini%2C_Gentile_-_Sultan_Mehmet_II.jpg"),
    OnThisDay(year: 1868, title: "江戶開城", text: "幕府將軍德川慶喜知其大勢已去，將大本營江戶城在無抵抗的狀況下移交給明治政府，歷史上又常稱為「無血開城」。", imageURL: "https://upload.wikimedia.org/wikipedia/commons/4/4b/Surrender_of_Edo_Castle_%28Meiji_Memorial_Picture_Gallery%29.jpg"),
    OnThisDay(year: 1928, title: "濟南事件", text: "日軍以保護僑民為由與國民革命軍交火，並屠殺城內平民。根據雙方說法，該事件造成 3600 至 6000 餘名平民死亡。", imageURL: "https://upload.wikimedia.org/wikipedia/commons/c/c0/Japanese_troops_in_Jinan_%28July_1927%29.png"),
    OnThisDay(year: 1979, title: "柴契爾當選首相", text: "瑪格麗特·柴契爾（1925-2013），為英國首位女性首相，亦是英國歷史上任期最長的首相之一。其強勢的領導風格使她被稱為「鐵娘子」。", imageURL: "https://upload.wikimedia.org/wikipedia/commons/a/a4/The_Queen_and_Margaret_Thatcher_1_July_1979_%286992989180%29.jpg")
]
