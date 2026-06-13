import SwiftUI

struct DetailReview: View {
    @State var review: Review

    init(_ review: Review) {
        self._review = State(initialValue: review)
    }

    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text(getRatingName(score: review.score))
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Score(score: review.score, showNumber: true)
            }
            .padding(.bottom, 5)
            
            VStack {
                Text("觀賞  \(toDateString(date: review.watched))")
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("評論  \(toDateString(date: review.created))")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.gray)
            }
            .padding(.bottom, 10)
            
            Text(review.comment)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.primary.opacity(0.8))
        }
    }
}

#Preview {
    let mockTarget: ReviewTarget = {
        let target = ReviewTarget("關於我轉生變成史萊姆這檔事", type: .drama)
        target.image = UIImage(resource: .placeholder)
        target.attributes = [
            ReviewAttributeValue(.releaseDate, "2018-10-01"),
            ReviewAttributeKeyValue(.link, ["巴哈姆特": "https://acg.gamer.com.tw/acgDetail.php?s=94601"])
        ]
        target.description = "三上無趣的人生突然走到盡頭，轉生到另一個世界，成為魔物史萊姆。他召集了一群魔物，掀起了巨大風暴。"
        target.reviews = [
            Review(score: 4.7, comment: "趁著第四季上映來二刷。本作描述上班族三上悟在街上因隨機攻擊而死後，轉生到異世界成為史萊姆「利姆路」，憑藉著強大且越來越多的技能逐漸建設自己的理想國的故事。第一季是我目前最喜歡的章節，因為前期戰力分配合理，而且從小村落逐漸發展為城鎮的建國譚很和我的胃口。", created: fromDateString(text: "2026-05-29") ?? Date(), watched: fromDateString(text: "2026-05-05") ?? Date()),
            Review(score: 4.5, comment: "蠻有趣的故事", created: fromDateString(text: "2024-02-02") ?? Date(), watched: fromDateString(text: "2024-02-02") ?? Date())
        ]
        return target
    }()
    
    DetailReview(mockTarget.reviews[0])
}
