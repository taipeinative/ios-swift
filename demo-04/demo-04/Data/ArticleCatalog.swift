import Foundation

struct ArticleCatalog: Hashable, Identifiable {
    let id: String
    let level: Int
    let name: String
    let icon: String
    let parentID: String?
}

struct ArticleLink: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let url: String
}

let ArticleCatalogData = [
    ArticleCatalog(id: "Art", level: 1, name: "藝文", icon: "paintpalette", parentID: nil),
    ArticleCatalog(id: "Ent", level: 1, name: "娛樂", icon: "film", parentID: nil),
    ArticleCatalog(id: "Sci", level: 1, name: "科學", icon: "sparkles", parentID: nil),
    ArticleCatalog(id: "Eng", level: 1, name: "工程", icon: "hammer", parentID: nil),
    ArticleCatalog(id: "Soc", level: 1, name: "社會", icon: "building.2", parentID: nil),
    ArticleCatalog(id: "Geo", level: 1, name: "地理", icon: "globe", parentID: nil),

    ArticleCatalog(id: "Art-Art", level: 2, name: "藝術", icon: "paintpalette", parentID: "Art"),
    ArticleCatalog(id: "Art-Cul", level: 2, name: "文化", icon: "theatermasks", parentID: "Art"),
    ArticleCatalog(id: "Art-Des", level: 2, name: "設計", icon: "scribble.variable", parentID: "Art"),
    ArticleCatalog(id: "Art-Foo", level: 2, name: "飲食", icon: "fork.knife", parentID: "Art"),

    ArticleCatalog(id: "Ent-Nov", level: 2, name: "小說", icon: "book", parentID: "Ent"),
    ArticleCatalog(id: "Ent-Mov", level: 2, name: "電影", icon: "film", parentID: "Ent"),
    ArticleCatalog(id: "Ent-Spo", level: 2, name: "運動", icon: "sportscourt", parentID: "Ent"),

    ArticleCatalog(id: "Sci-Mat", level: 2, name: "數學", icon: "numbers", parentID: "Sci"),
    ArticleCatalog(id: "Sci-Phy", level: 2, name: "物理學", icon: "atom", parentID: "Sci"),
    ArticleCatalog(id: "Sci-Che", level: 2, name: "化學", icon: "eyedropper", parentID: "Sci"),
    ArticleCatalog(id: "Sci-Med", level: 2, name: "醫學", icon: "stethoscope", parentID: "Sci"),
    ArticleCatalog(id: "Sci-Agr", level: 2, name: "農學", icon: "carrot", parentID: "Sci"),
    ArticleCatalog(id: "Sci-Bio", level: 2, name: "生物學", icon: "lizard.fill", parentID: "Sci"),

    ArticleCatalog(id: "Eng-Arc", level: 2, name: "建築", icon: "building.fill", parentID: "Eng"),
    ArticleCatalog(id: "Eng-Mec", level: 2, name: "機械", icon: "gear", parentID: "Eng"),
    ArticleCatalog(id: "Eng-Ene", level: 2, name: "能源", icon: "bolt.fill", parentID: "Eng"),
    ArticleCatalog(id: "Eng-Tra", level: 2, name: "交通", icon: "car", parentID: "Eng"),
    ArticleCatalog(id: "Eng-Inf", level: 2, name: "資訊", icon: "desktopcomputer", parentID: "Eng"),

    ArticleCatalog(id: "Soc-Phi", level: 2, name: "哲學", icon: "book", parentID: "Soc"),
    ArticleCatalog(id: "Soc-His", level: 2, name: "歷史", icon: "building.columns", parentID: "Soc"),
    ArticleCatalog(id: "Soc-Pol", level: 2, name: "政治", icon: "shield.righthalf.filled", parentID: "Soc"),
    ArticleCatalog(id: "Soc-Eco", level: 2, name: "經濟", icon: "dollarsign", parentID: "Soc"),
    ArticleCatalog(id: "Soc-Soc", level: 2, name: "社會學", icon: "person.2.fill", parentID: "Soc"),
    ArticleCatalog(id: "Soc-Law", level: 2, name: "法律", icon: "briefcase", parentID: "Soc"),

    ArticleCatalog(id: "Geo-Asi", level: 2, name: "亞洲", icon: "globe", parentID: "Geo"),
    ArticleCatalog(id: "Geo-Eur", level: 2, name: "歐洲", icon: "globe", parentID: "Geo"),
    ArticleCatalog(id: "Geo-Ame", level: 2, name: "美洲", icon: "globe", parentID: "Geo"),
    ArticleCatalog(id: "Geo-Afr", level: 2, name: "非洲", icon: "globe", parentID: "Geo"),
    ArticleCatalog(id: "Geo-Oce", level: 2, name: "大洋洲", icon: "globe", parentID: "Geo"),
    ArticleCatalog(id: "Geo-Ant", level: 2, name: "南極洲", icon: "globe", parentID: "Geo")
]

let ArticleCatalogLinks: [String: [ArticleLink]] = [
    "Art-Art": [
        ArticleLink(title: "藝術", url: "https://zh.wikipedia.org/zh-tw/藝術"),
        ArticleLink(title: "文藝復興", url: "https://zh.wikipedia.org/zh-tw/文藝復興"),
        ArticleLink(title: "巴洛克藝術", url: "https://zh.wikipedia.org/zh-tw/巴洛克藝術"),
        ArticleLink(title: "印象派", url: "https://zh.wikipedia.org/zh-tw/印象派"),
        ArticleLink(title: "現代藝術", url: "https://zh.wikipedia.org/zh-tw/現代藝術")
    ],
    "Art-Cul": [
        ArticleLink(title: "文化", url: "https://zh.wikipedia.org/zh-tw/文化"),
        ArticleLink(title: "民俗", url: "https://zh.wikipedia.org/zh-tw/民俗"),
        ArticleLink(title: "語言", url: "https://zh.wikipedia.org/zh-tw/語言"),
        ArticleLink(title: "宗教", url: "https://zh.wikipedia.org/zh-tw/宗教"),
        ArticleLink(title: "節日", url: "https://zh.wikipedia.org/zh-tw/節日")
    ],
    "Art-Des": [
        ArticleLink(title: "設計", url: "https://zh.wikipedia.org/zh-tw/設計"),
        ArticleLink(title: "平面設計", url: "https://zh.wikipedia.org/zh-tw/平面設計"),
        ArticleLink(title: "工業設計", url: "https://zh.wikipedia.org/zh-tw/工業設計"),
        ArticleLink(title: "服裝設計", url: "https://zh.wikipedia.org/zh-tw/服裝設計"),
        ArticleLink(title: "使用者體驗設計", url: "https://zh.wikipedia.org/zh-tw/使用者體驗設計")
    ],
    "Art-Foo": [
        ArticleLink(title: "中華料理", url: "https://zh.wikipedia.org/zh-tw/中華料理"),
        ArticleLink(title: "日本料理", url: "https://zh.wikipedia.org/zh-tw/日本料理"),
        ArticleLink(title: "義大利菜", url: "https://zh.wikipedia.org/zh-tw/義大利菜"),
        ArticleLink(title: "烘焙", url: "https://zh.wikipedia.org/zh-tw/烘焙"),
        ArticleLink(title: "食品科學", url: "https://zh.wikipedia.org/zh-tw/食品科學")
    ],
    "Ent-Nov": [
        ArticleLink(title: "小說", url: "https://zh.wikipedia.org/zh-tw/小說"),
        ArticleLink(title: "科幻小說", url: "https://zh.wikipedia.org/zh-tw/科幻小說"),
        ArticleLink(title: "偵探小說", url: "https://zh.wikipedia.org/zh-tw/偵探小說"),
        ArticleLink(title: "網路小說", url: "https://zh.wikipedia.org/zh-tw/網路小說"),
        ArticleLink(title: "言情小說", url: "https://zh.wikipedia.org/zh-tw/言情小說")
    ],
    "Ent-Mov": [
        ArticleLink(title: "電影", url: "https://zh.wikipedia.org/zh-tw/電影"),
        ArticleLink(title: "導演", url: "https://zh.wikipedia.org/zh-tw/導演"),
        ArticleLink(title: "劇本", url: "https://zh.wikipedia.org/zh-tw/劇本"),
        ArticleLink(title: "票房", url: "https://zh.wikipedia.org/zh-tw/票房"),
        ArticleLink(title: "奧斯卡金像獎", url: "https://zh.wikipedia.org/zh-tw/奧斯卡金像獎")
    ],
    "Ent-Spo": [
        ArticleLink(title: "足球", url: "https://zh.wikipedia.org/zh-tw/足球"),
        ArticleLink(title: "籃球", url: "https://zh.wikipedia.org/zh-tw/籃球"),
        ArticleLink(title: "奧林匹克運動會", url: "https://zh.wikipedia.org/zh-tw/奧林匹克運動會"),
        ArticleLink(title: "田徑", url: "https://zh.wikipedia.org/zh-tw/田徑"),
        ArticleLink(title: "網球", url: "https://zh.wikipedia.org/zh-tw/網球")
    ],
    "Sci-Mat": [
        ArticleLink(title: "數學", url: "https://zh.wikipedia.org/zh-tw/數學"),
        ArticleLink(title: "代數", url: "https://zh.wikipedia.org/zh-tw/代數"),
        ArticleLink(title: "幾何", url: "https://zh.wikipedia.org/zh-tw/幾何"),
        ArticleLink(title: "微積分", url: "https://zh.wikipedia.org/zh-tw/微積分"),
        ArticleLink(title: "統計學", url: "https://zh.wikipedia.org/zh-tw/統計學")
    ],
    "Sci-Phy": [
        ArticleLink(title: "物理學", url: "https://zh.wikipedia.org/zh-tw/物理學"),
        ArticleLink(title: "量子力學", url: "https://zh.wikipedia.org/zh-tw/量子力學"),
        ArticleLink(title: "相對論", url: "https://zh.wikipedia.org/zh-tw/相對論"),
        ArticleLink(title: "熱力學", url: "https://zh.wikipedia.org/zh-tw/熱力學"),
        ArticleLink(title: "電磁學", url: "https://zh.wikipedia.org/zh-tw/電磁學")
    ],
    "Sci-Che": [
        ArticleLink(title: "化學", url: "https://zh.wikipedia.org/zh-tw/化學"),
        ArticleLink(title: "有機化學", url: "https://zh.wikipedia.org/zh-tw/有機化學"),
        ArticleLink(title: "無機化學", url: "https://zh.wikipedia.org/zh-tw/無機化學"),
        ArticleLink(title: "物理化學", url: "https://zh.wikipedia.org/zh-tw/物理化學"),
        ArticleLink(title: "分析化學", url: "https://zh.wikipedia.org/zh-tw/分析化學")
    ],
    "Sci-Med": [
        ArticleLink(title: "醫學", url: "https://zh.wikipedia.org/zh-tw/醫學"),
        ArticleLink(title: "外科學", url: "https://zh.wikipedia.org/zh-tw/外科學"),
        ArticleLink(title: "內科學", url: "https://zh.wikipedia.org/zh-tw/內科學"),
        ArticleLink(title: "免疫學", url: "https://zh.wikipedia.org/zh-tw/免疫學"),
        ArticleLink(title: "傳染病", url: "https://zh.wikipedia.org/zh-tw/傳染病")
    ],
    "Sci-Agr": [
        ArticleLink(title: "農學", url: "https://zh.wikipedia.org/zh-tw/農學"),
        ArticleLink(title: "作物", url: "https://zh.wikipedia.org/zh-tw/作物"),
        ArticleLink(title: "土壤學", url: "https://zh.wikipedia.org/zh-tw/土壤學"),
        ArticleLink(title: "農業機械", url: "https://zh.wikipedia.org/zh-tw/農業機械"),
        ArticleLink(title: "有機農業", url: "https://zh.wikipedia.org/zh-tw/有機農業")
    ],
    "Sci-Bio": [
        ArticleLink(title: "生物學", url: "https://zh.wikipedia.org/zh-tw/生物學"),
        ArticleLink(title: "細胞", url: "https://zh.wikipedia.org/zh-tw/細胞"),
        ArticleLink(title: "遺傳學", url: "https://zh.wikipedia.org/zh-tw/遺傳學"),
        ArticleLink(title: "生態學", url: "https://zh.wikipedia.org/zh-tw/生態學"),
        ArticleLink(title: "微生物", url: "https://zh.wikipedia.org/zh-tw/微生物")
    ],
    "Eng-Arc": [
        ArticleLink(title: "建築", url: "https://zh.wikipedia.org/zh-tw/建築"),
        ArticleLink(title: "建築學", url: "https://zh.wikipedia.org/zh-tw/建築學"),
        ArticleLink(title: "都市計畫", url: "https://zh.wikipedia.org/zh-tw/都市計畫"),
        ArticleLink(title: "建築結構", url: "https://zh.wikipedia.org/zh-tw/建築結構"),
        ArticleLink(title: "建築材料", url: "https://zh.wikipedia.org/zh-tw/建築材料")
    ],
    "Eng-Mec": [
        ArticleLink(title: "機械工程", url: "https://zh.wikipedia.org/zh-tw/機械工程"),
        ArticleLink(title: "機械", url: "https://zh.wikipedia.org/zh-tw/機械"),
        ArticleLink(title: "機器人", url: "https://zh.wikipedia.org/zh-tw/機器人"),
        ArticleLink(title: "熱機", url: "https://zh.wikipedia.org/zh-tw/熱機"),
        ArticleLink(title: "自動化", url: "https://zh.wikipedia.org/zh-tw/自動化")
    ],
    "Eng-Ene": [
        ArticleLink(title: "能源", url: "https://zh.wikipedia.org/zh-tw/能源"),
        ArticleLink(title: "可再生能源", url: "https://zh.wikipedia.org/zh-tw/可再生能源"),
        ArticleLink(title: "太陽能", url: "https://zh.wikipedia.org/zh-tw/太陽能"),
        ArticleLink(title: "風能", url: "https://zh.wikipedia.org/zh-tw/風能"),
        ArticleLink(title: "核能", url: "https://zh.wikipedia.org/zh-tw/核能")
    ],
    "Eng-Tra": [
        ArticleLink(title: "交通", url: "https://zh.wikipedia.org/zh-tw/交通"),
        ArticleLink(title: "運輸", url: "https://zh.wikipedia.org/zh-tw/運輸"),
        ArticleLink(title: "軌道交通", url: "https://zh.wikipedia.org/zh-tw/軌道交通"),
        ArticleLink(title: "航空", url: "https://zh.wikipedia.org/zh-tw/航空"),
        ArticleLink(title: "航運", url: "https://zh.wikipedia.org/zh-tw/航運")
    ],
    "Eng-Inf": [
        ArticleLink(title: "資訊科技", url: "https://zh.wikipedia.org/zh-tw/資訊科技"),
        ArticleLink(title: "計算機科學", url: "https://zh.wikipedia.org/zh-tw/計算機科學"),
        ArticleLink(title: "軟體工程", url: "https://zh.wikipedia.org/zh-tw/軟體工程"),
        ArticleLink(title: "網際網路", url: "https://zh.wikipedia.org/zh-tw/網際網路"),
        ArticleLink(title: "人工智慧", url: "https://zh.wikipedia.org/zh-tw/人工智慧")
    ],
    "Soc-Phi": [
        ArticleLink(title: "哲學", url: "https://zh.wikipedia.org/zh-tw/哲學"),
        ArticleLink(title: "倫理學", url: "https://zh.wikipedia.org/zh-tw/倫理學"),
        ArticleLink(title: "形而上學", url: "https://zh.wikipedia.org/zh-tw/形而上學"),
        ArticleLink(title: "邏輯", url: "https://zh.wikipedia.org/zh-tw/邏輯"),
        ArticleLink(title: "認識論", url: "https://zh.wikipedia.org/zh-tw/認識論")
    ],
    "Soc-His": [
        ArticleLink(title: "歷史", url: "https://zh.wikipedia.org/zh-tw/歷史"),
        ArticleLink(title: "史學", url: "https://zh.wikipedia.org/zh-tw/史學"),
        ArticleLink(title: "世界歷史", url: "https://zh.wikipedia.org/zh-tw/世界歷史"),
        ArticleLink(title: "史前史", url: "https://zh.wikipedia.org/zh-tw/史前史"),
        ArticleLink(title: "中世紀", url: "https://zh.wikipedia.org/zh-tw/中世紀")
    ],
    "Soc-Pol": [
        ArticleLink(title: "政治", url: "https://zh.wikipedia.org/zh-tw/政治"),
        ArticleLink(title: "政治學", url: "https://zh.wikipedia.org/zh-tw/政治學"),
        ArticleLink(title: "民主", url: "https://zh.wikipedia.org/zh-tw/民主"),
        ArticleLink(title: "選舉", url: "https://zh.wikipedia.org/zh-tw/選舉"),
        ArticleLink(title: "政黨", url: "https://zh.wikipedia.org/zh-tw/政黨")
    ],
    "Soc-Eco": [
        ArticleLink(title: "經濟學", url: "https://zh.wikipedia.org/zh-tw/經濟學"),
        ArticleLink(title: "宏觀經濟學", url: "https://zh.wikipedia.org/zh-tw/宏觀經濟學"),
        ArticleLink(title: "微觀經濟學", url: "https://zh.wikipedia.org/zh-tw/微觀經濟學"),
        ArticleLink(title: "貨幣", url: "https://zh.wikipedia.org/zh-tw/貨幣"),
        ArticleLink(title: "通貨膨脹", url: "https://zh.wikipedia.org/zh-tw/通貨膨脹")
    ],
    "Soc-Soc": [
        ArticleLink(title: "社會學", url: "https://zh.wikipedia.org/zh-tw/社會學"),
        ArticleLink(title: "社會結構", url: "https://zh.wikipedia.org/zh-tw/社會結構"),
        ArticleLink(title: "社會問題", url: "https://zh.wikipedia.org/zh-tw/社會問題"),
        ArticleLink(title: "社會化", url: "https://zh.wikipedia.org/zh-tw/社會化"),
        ArticleLink(title: "社會階層", url: "https://zh.wikipedia.org/zh-tw/社會階層")
    ],
    "Soc-Law": [
        ArticleLink(title: "法律", url: "https://zh.wikipedia.org/zh-tw/法律"),
        ArticleLink(title: "法學", url: "https://zh.wikipedia.org/zh-tw/法學"),
        ArticleLink(title: "憲法", url: "https://zh.wikipedia.org/zh-tw/憲法"),
        ArticleLink(title: "刑法", url: "https://zh.wikipedia.org/zh-tw/刑法"),
        ArticleLink(title: "民法", url: "https://zh.wikipedia.org/zh-tw/民法")
    ],
    "Geo-Asi": [
        ArticleLink(title: "亞洲", url: "https://zh.wikipedia.org/zh-tw/亞洲"),
        ArticleLink(title: "中國", url: "https://zh.wikipedia.org/zh-tw/中國"),
        ArticleLink(title: "日本", url: "https://zh.wikipedia.org/zh-tw/日本"),
        ArticleLink(title: "印度", url: "https://zh.wikipedia.org/zh-tw/印度"),
        ArticleLink(title: "東南亞", url: "https://zh.wikipedia.org/zh-tw/東南亞")
    ],
    "Geo-Eur": [
        ArticleLink(title: "歐洲", url: "https://zh.wikipedia.org/zh-tw/歐洲"),
        ArticleLink(title: "德國", url: "https://zh.wikipedia.org/zh-tw/德國"),
        ArticleLink(title: "法國", url: "https://zh.wikipedia.org/zh-tw/法國"),
        ArticleLink(title: "義大利", url: "https://zh.wikipedia.org/zh-tw/義大利"),
        ArticleLink(title: "英國", url: "https://zh.wikipedia.org/zh-tw/英國")
    ],
    "Geo-Ame": [
        ArticleLink(title: "美洲", url: "https://zh.wikipedia.org/zh-tw/美洲"),
        ArticleLink(title: "北美洲", url: "https://zh.wikipedia.org/zh-tw/北美洲"),
        ArticleLink(title: "南美洲", url: "https://zh.wikipedia.org/zh-tw/南美洲"),
        ArticleLink(title: "美國", url: "https://zh.wikipedia.org/zh-tw/美國"),
        ArticleLink(title: "巴西", url: "https://zh.wikipedia.org/zh-tw/巴西")
    ],
    "Geo-Afr": [
        ArticleLink(title: "非洲", url: "https://zh.wikipedia.org/zh-tw/非洲"),
        ArticleLink(title: "埃及", url: "https://zh.wikipedia.org/zh-tw/埃及"),
        ArticleLink(title: "奈及利亞", url: "https://zh.wikipedia.org/zh-tw/奈及利亞"),
        ArticleLink(title: "南非", url: "https://zh.wikipedia.org/zh-tw/南非"),
        ArticleLink(title: "撒哈拉以南非洲", url: "https://zh.wikipedia.org/zh-tw/撒哈拉以南非洲")
    ],
    "Geo-Oce": [
        ArticleLink(title: "大洋洲", url: "https://zh.wikipedia.org/zh-tw/大洋洲"),
        ArticleLink(title: "澳大利亞", url: "https://zh.wikipedia.org/zh-tw/澳大利亞"),
        ArticleLink(title: "紐西蘭", url: "https://zh.wikipedia.org/zh-tw/紐西蘭"),
        ArticleLink(title: "巴布亞紐幾內亞", url: "https://zh.wikipedia.org/zh-tw/巴布亞紐幾內亞"),
        ArticleLink(title: "玻里尼西亞", url: "https://zh.wikipedia.org/zh-tw/玻里尼西亞")
    ],
    "Geo-Ant": [
        ArticleLink(title: "南極洲", url: "https://zh.wikipedia.org/zh-tw/南極洲"),
        ArticleLink(title: "南極", url: "https://zh.wikipedia.org/zh-tw/南極"),
        ArticleLink(title: "南極半島", url: "https://zh.wikipedia.org/zh-tw/南極半島"),
        ArticleLink(title: "南極條約", url: "https://zh.wikipedia.org/zh-tw/南極條約"),
        ArticleLink(title: "南極研究站", url: "https://zh.wikipedia.org/zh-tw/南極研究站")
    ]
]
