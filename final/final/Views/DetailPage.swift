import SwiftUI

struct DetailPage: View {
    @State var reviewTarget: ReviewTarget
    @State private var selectedReviewIndex: Int? = nil
    
    // Callbacks to bubble navigation up to ContentView
    var onNavigateToEdit: () -> Void
    var onPopToRoot: () -> Void
    
    init(_ reviewTarget: ReviewTarget, onNavigateToEdit: @escaping () -> Void, onPopToRoot: @escaping () -> Void) {
        self._reviewTarget = State(initialValue: reviewTarget)
        self.onNavigateToEdit = onNavigateToEdit
        self.onPopToRoot = onPopToRoot
    }
    
    var body: some View {
        let desc = reviewTarget.description
        let links = reviewTarget.getURLs()
        let sortedReviews = reviewTarget.reviews.sorted(by: { $0.created > $1.created })
        
        ScrollView {
            ReviewObject(reviewTarget.image, reviewTarget.name, reviewTarget.type, reviewTarget.getReleaseDate())
                .padding(.bottom, 10)
                .padding(.horizontal, 35)
            
            if let intro = desc {
                SubHeading(text: "作品簡介", isProminent: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 3)
                    .padding(.horizontal, 35)
                
                Text(intro)
                    .font(.callout)
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 34)
            }
            
            if !links.isEmpty {
                SubHeading(text: "相關連結", isProminent: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, desc != nil ? 6 : 0)
                    .padding(.bottom, 3)
                    .padding(.horizontal, 35)
                
                LinkGrocery(links)
                    .padding(.horizontal, 35)
            }
            
            HStack {
                SubHeading(text: "評論", isProminent: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, (desc != nil || !links.isEmpty) ? 6 : 0)
                    .padding(.bottom, 3)
                
                Spacer()
                
                Picker("篩選評論", selection: $selectedReviewIndex) {
                    Text("全部評論").tag(Int?.none)
                    ForEach(0..<sortedReviews.count, id: \.self) { displayOrder in
                        let historicalNumber = displayOrder + 1
                        let correspondingSortedIndex = (sortedReviews.count - 1) - displayOrder
                        Text("第\(historicalNumber)次評論").tag(Int?.some(correspondingSortedIndex))
                    }
                }
                .pickerStyle(.menu)
                .tint(.blue)
            }
            .padding(.horizontal, 35)
            
            ForEach(0..<sortedReviews.count, id: \.self) { index in
                if selectedReviewIndex == nil || selectedReviewIndex == index {
                    DetailReview(sortedReviews[index])
                        .padding(.horizontal, 35)
                        .padding(.bottom, 20)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: onNavigateToEdit) { // 👈 Triggers Edit Modal sheet wrapper
                    Image(systemName: "pencil")
                        .foregroundStyle(.blue)
                }
            }
            
            // 1. Secondary ToolbarItem providing direct link to escape to MainPage index
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onPopToRoot) {
                    Image(systemName: "house")
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

//#Preview("Detailed Page With Intro") {
//    DetailPage(mockTarget)
//}
//
//#Preview("Detailed Page Without Intro") {
//    let mockTarget2: ReviewTarget = {
//        let target = ReviewTarget("關於我轉生變成史萊姆這檔事", type: .drama)
//        target.image = UIImage(resource: .placeholder)
//        target.attributes = [
//            ReviewAttributeValue(.releaseDate, "2018-10-01")
//        ]
//        target.reviews = [
//            Review(score: 4.7, comment: "趁著第四季上映來二刷。本作描述上班族三上悟在街上因隨機攻擊而死後，轉生到異世界成為史萊姆「利姆路」，憑藉著強大且越來越多的技能逐漸建設自己的理想國的故事。第一季是我目前最喜歡的章節，因為前期戰力分配合理，而且從小村落逐漸發展為城鎮的建國譚很和我的胃口。", created: fromDateString(text: "2026-05-29") ?? Date(), watched: fromDateString(text: "2026-05-05") ?? Date(), count: 2),
//            Review(score: 4.5, comment: "蠻有趣的故事。第二季好像會變成開會番？", created: fromDateString(text: "2024-02-02") ?? Date(), watched: fromDateString(text: "2024-02-02") ?? Date(), count: 1)
//        ]
//        return target
//    }()
//    DetailPage(mockTarget2)
//}
