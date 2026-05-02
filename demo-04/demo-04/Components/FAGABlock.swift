import SwiftUI
import WebKit

struct ArticlePreview: View {
    let title: String
    let desc: String
    let imageURL: String
    let targetURL: String
    @State private var isShowingWebView = false
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImageHelper(urlString: imageURL, height: 200)
            
            Button {
                isShowingWebView = true
            } label: {
                HStack(alignment: .center) {
                    Text(title)
                        .font(.title2)
                        .foregroundStyle(.primary)
                    
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 7)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 3)
            .sheet(isPresented: $isShowingWebView) {
                if let url = URL(string: targetURL) {
                    NavigationStack {
                        LinkHelper(url: url)
                            .ignoresSafeArea()
                            .navigationTitle(title)
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
            
            Text(desc)
                .foregroundStyle(.secondary)
            
        }
        .padding(.horizontal, 10)
    }
}

struct FAGABlock: View {
    var body: some View {
        Header(title: "典範條目", small: true)
            .padding(.top, 15)
        
        ArticlePreview(title: "冬季戰爭",
                       desc: "自1939年11月30日由蘇聯向芬蘭發動進攻而展開，蘇聯最終慘勝於芬蘭，令其割讓與租借部份領土，而後於1940年3月13日雙方簽訂《莫斯科和平協定》為結束。",
                       imageURL: "https://upload.wikimedia.org/wikipedia/commons/a/a8/Finnish-lightmachinegun-skis-winterwar.png",
                       targetURL: "https://zh.wikipedia.org/zh-tw/冬季战争")
        
        Header(title: "優良條目", small: true)
            .padding(.top, 15)
        
        ArticlePreview(title: "星露谷物語",
                       desc: "埃里克·巴龍開發的農場生活模擬遊戲，2016年問世。玩家扮演一名繼承祖父破舊農場的角色，在名為星露谷的地方開墾土地、種植時令作物、飼養牲畜，經營自己的農場。",
                       imageURL: "https://upload.wikimedia.org/wikipedia/zh/9/96/Stardew_valley_screenshot.png",
                       targetURL: "https://zh.wikipedia.org/zh-tw/星露谷物语")
    }
}

#Preview {
    FAGABlock()
}
