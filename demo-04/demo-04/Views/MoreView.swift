import SwiftUI
import WebKit

struct Donation: View {
    var body: some View {
        WebView(url: URL(string: "https://donate.wikimedia.org/?wmf_source=donate&wmf_medium=sidebar&wmf_campaign=zh.wikipedia.org&uselang=zh"))
    }
}

struct MoreView: View {
    @State private var showDonation: Bool = false
    
    private let sisterProjects: [(title: String, emblemURL: String, intro: String)] = [
        (
            title: "維基詞典",
            emblemURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Wiktionary-logo.svg/960px-Wiktionary-logo.svg.png",
            intro: "協作編寫與維護的多語詞典，提供釋義、發音與詞源。"
        ),
        (
            title: "維基教科書",
            emblemURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Wikibooks-logo.svg/500px-Wikibooks-logo.svg.png",
            intro: "開放式教科書與學習資源，涵蓋各領域教材與指南。"
        ),
        (
            title: "維基語錄",
            emblemURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Wikiquote-logo.svg/500px-Wikiquote-logo.svg.png",
            intro: "收錄名人名言與文句出處的協作語錄庫。"
        ),
        (
            title: "維基共享資源",
            emblemURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Commons-logo.svg/500px-Commons-logo.svg.png",
            intro: "自由媒體素材庫，包含圖片、音訊與影片等檔案。"
        ),
        (
            title: "維基學院",
            emblemURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Wikiversity-logo.svg/960px-Wikiversity-logo.svg.png",
            intro: "開放式學習與研究平台，鼓勵建立課程與研究社群。"
        ),
        (
            title: "維基數據",
            emblemURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/Wikidata-logo.svg/960px-Wikidata-logo.svg.png",
            intro: "開放資料庫，系統性連結各計劃與各語言版本間的資訊。"
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Header(title: "姊妹計劃", serif: true)
                    .padding(.vertical, 20)
                
                Group {
                    Text("維基媒體基金會除了營運維基百科外，尚有其他內容開放的維基計劃：")
                    VStack(spacing: 16) {
                        List {
                            ForEach(sisterProjects, id: \.title) { project in
                                HStack(alignment: .top, spacing: 12) {
                                    AsyncImageHelper(urlString: project.emblemURL, height: 44)
                                        .frame(width: 30)
                                        .padding(.trailing, 10)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(project.title)
                                            .font(.headline)
                                        Text(project.intro)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(height: 630)
                        .scrollContentBackground(.hidden)
                        .background(.clear)
                        .listStyle(.plain)
                    }
                    .padding(.top, 12)
                }
                .padding(.leading, 10)
                
                Header(title: "資助維基", serif: true)
                    .padding(.bottom, 20)
                
                Group {
                    Group {
                        Text("維基百科是網路上排名第五的網站，每月有四億五千萬人次使用，頁面瀏覽以十億計。")
                        Text("商業本無錯，廣告亦非惡，但是他們不屬於這裡、不屬於維基百科。")
                        Text("維基百科跟其他的網站不同。它像是個圖書館、又像是公園，也是心靈之殿。它是讓我們思考、學習以及分享知識的地方。")
                        Text("維基百科草創之時，我本可拿它來謀利，經營成刊載廣告的商業公司，但我決定做些與眾不同的事。我們多年来精簡節流，勤於此命，以免支出過多，浪費有餘。")
                        Text("如果每位讀到這篇文章的人都能捐出NT$150, NT$300, NT$500，那麼我們每年募款的目標只要一日就可以募足了。不過並不是每個人都有心力給予我們協助。這沒關係，幫助我們的人，每年適量就可以了。")
                        Text("今年在這裡誠心懇求各位襄助，無論是NT$150, NT$300, NT$500還是多少皆可，以確保維基百科的運行。")
                        Text("感激不盡，")
                    }
                    .padding(.vertical, 5)
                    
                    Text("吉米・威爾士")
                        .fontWeight(.bold)
                    
                    Text("維基百科創始人")
                    
                    Button {
                        showDonation = true
                    } label: {
                        HStack {
                            Text("前往捐款")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                        }
                        .font(.title3)
                    }
                    .padding(.vertical, 10)
                    .padding(.bottom, 50)
                    .sheet(isPresented: $showDonation) {
                        Donation()
                    }
                }
                .padding(.leading, 10)
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    MoreView()
}
