import SwiftUI

struct Score: View {
    let score: Float
    var showNumber: Bool = false
    
    var body: some View {
        let starCount = max(0, Int(score.rounded(.up)))
        
        if showNumber {
            HStack(spacing: 5) {
                Text(String(repeating: "★", count: starCount))
                    .foregroundStyle(.orange)
                Text(String(format: "%.1f", score))
                    .fontWeight(.medium)
            }
        } else {
            Text(String(repeating: "★", count: starCount))
                .foregroundStyle(.orange)
        }
    }
}

#Preview {
    Score(score: 1.0)
    Score(score: 1.0, showNumber: true)
    Score(score: 4.5)
    Score(score: 4.5, showNumber: true)
}
