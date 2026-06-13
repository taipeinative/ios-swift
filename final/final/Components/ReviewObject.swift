import SwiftUI

struct ReviewObject: View {
    @State var image: UIImage
    @State var title: String
    @State var reviewType: ReviewType
    @State var releaseDate: Date
    
    init(_ image: UIImage, _ title: String, _ reviewType: ReviewType = ReviewType.other, _ releaseDate: Date = Date()) {
        self._image = State(initialValue: image)
        self._title = State(initialValue: title)
        self._reviewType = State(initialValue: reviewType)
        self._releaseDate = State(initialValue: releaseDate)
    }
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: 250)
                .padding(.bottom, 10)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.bottom, 2)
            
            Text("\(reviewType.getTitle()) ·  \(releaseDate.formatted(.dateTime.year()))")
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    ReviewObject(UIImage(resource: .placeholder), "關於我轉生變成史萊姆這檔事", ReviewType.drama, fromDateString(text: "2018-10-01") ?? Date())
}
