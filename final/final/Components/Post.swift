import ColorKit
import SwiftUI

struct Post: View {
    @State var comment: String
    @State var reviewCount: Int
    @State var reviewDate: Date
    @State var reviewType: ReviewType
    @State var score: Float
    @State var title: String
    @State var image: UIImage
    
    @State private var isLoaded: Bool = false
    @State private var imageBackgroundColor: Color = Color(.systemBackground)
    
    init(_ title: String, _ score: Float, _ comment: String = "", _ reviewType: ReviewType = ReviewType.location, _ reviewDate: Date = Date(), _ reviewCount: Int = 1, image: UIImage = UIImage(resource: .placeholder)) {
        self._title = State(initialValue: title)
        self._score = State(initialValue: score)
        self._comment = State(initialValue: comment)
        self._reviewType = State(initialValue: reviewType)
        self._reviewDate = State(initialValue: reviewDate)
        self._reviewCount = State(initialValue: reviewCount)
        self.image = image
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 190)
                .opacity(isLoaded ? 1.0 : 0.0)
                .background(imageBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            
            HStack {
                SubHeading(text: title)
                    .lineLimit(1)
                Spacer()
                Score(score: score)
            }
            
            Text(comment)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 0) {
                Text("\(reviewType.getTitle()) · \(toDateString(date: reviewDate)) · ")
                Text("第\(reviewCount)次評論")
                    .foregroundStyle(reviewCount == 1 ? .blue : .gray)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.bottom, 30)
        .task {
            await updateImageBackground()
        }
    }
    
    private func updateImageBackground() async {
        if let extractedColor = await extractAverageColor(from: image) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.imageBackgroundColor = extractedColor
                    self.isLoaded = true
                }
            } else {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.isLoaded = true
                }
            }
    }
}

#Preview {
    VStack {
        Post("武吉蛋包飯", 4.5, "憑學生證可以打折，還不錯吃。圖文不符，我點的是茄汁肉醬蛋包飯，肉醬味道很濃郁，", ReviewType.location, fromDateString(text: "2025-05-30") ?? Date())
        Post("True North (2026)", 2.5, "Jason Ross 睽違四年的新專輯，多數表現平平，另外這張專輯的曲風已經變成 House 了，必須說", ReviewType.music, fromDateString(text: "2025-05-29") ?? Date())
    }
        .padding(.horizontal, 35)
}
