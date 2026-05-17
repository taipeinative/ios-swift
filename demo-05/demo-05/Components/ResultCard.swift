import SwiftUI

struct ResultCard: View {
    let index: Int
    let q: Question
    let ans: CustomColor
    let isCorrect: Bool
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Circle()
                    .fill(q.backgroundColor)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                
                VStack(alignment: .leading) {
                    Text("Q\(index + 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(q.correctOption.name)
                        .font(.subheadline)
                }
                
                Spacer()
                
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? .green : .red)
                    .font(.title2)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if !isCorrect {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
            
            if isExpanded && !isCorrect {
                VStack(alignment: .leading, spacing: 4) {
                    Divider()
                        .padding(.vertical, 8)
                    Text("你選擇了：")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(ans.name)
                        .font(.subheadline)
                        .strikethrough()
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}
