import SwiftUI

struct OnThisDayBlock: View {
    var body: some View {
        Header(title: "歷史上的今天", small: true)
        TabView {
            ForEach(OnThisDayData) { item in
                VStack(alignment: .leading, spacing: 8) {
                    AsyncImageHelper(urlString: item.imageURL, height: 200)

                    Text("\(String(item.year))年5月3日・\(item.title)")
                        .font(.headline)

                    Text(item.text)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                }
                .frame(maxHeight: .infinity, alignment: .topLeading)
                .padding([.trailing], 10)
            }
        }
        .frame(height: 370)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .padding([.top], 5)
        .padding(.horizontal, 10)
    }
}