import SwiftUI

struct ResultView: View {
    var gameManager: GameManager
    
    @State private var stage = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("測驗結果")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 100)
                    .opacity(stage >= 1 ? 1 : 0)
                
                VStack(spacing: 20) {
                    Text("得分：\(gameManager.score) / 10")
                        .font(.title)
                        .foregroundColor(gameManager.score > 5 ? .green : .orange)
                    
                    HStack(spacing: 20) {
                        Button(action: { gameManager.restart() }) {
                            Text("重新開始")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        
                        ShareLink(item: "我在色彩名稱測驗中得到了 \(gameManager.score) / 10 分！") {
                            Label("炫耀", systemImage: "square.and.arrow.up")
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.bottom)
                .opacity(stage >= 2 ? 1 : 0)
                
                VStack(spacing: 10) {
                    ForEach(Array(gameManager.results.enumerated()), id: \.offset) { index, result in
                        let (q, ans) = result
                        let isCorrect = ans.id == q.correctOption.id
                        
                        ResultCard(index: index, q: q, ans: ans, isCorrect: isCorrect)
                            .padding(.horizontal)
                    }
                }
                .opacity(stage >= 3 ? 1 : 0)
            }
            .padding(.bottom, 40)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                stage = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.3)) {
                    stage = 2
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeIn(duration: 0.3)) {
                    stage = 3
                }
            }
        }
    }
}