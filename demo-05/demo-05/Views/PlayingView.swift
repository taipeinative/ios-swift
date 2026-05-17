import SwiftUI

struct PlayingView: View {
    var gameManager: GameManager
    
    var body: some View {
        let question = gameManager.questions[gameManager.currentQuestionIndex]
        
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            if isLandscape {
                // Left - Right layout for landscape
                HStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        question.backgroundColor
                            .edgesIgnoringSafeArea(.all)
                        
                        Text("問題 \(gameManager.currentQuestionIndex + 1) / 10")
                            .font(.headline)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                            .padding(.top, 20)
                    }
                    
                    VStack(spacing: 15) {
                        Spacer()
                        
                        Text("選擇最符合背景色的名稱：")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        ForEach(question.options) { option in
                            Button(action: {
                                gameManager.selectAnswer(option)
                            }) {
                                Text(option.name)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Spacer()
                    }
                    .id(gameManager.currentQuestionIndex)
                    .padding(.horizontal, 40)
                    .frame(width: geometry.size.width * 0.45)
                    .background(Color(UIColor.systemBackground))
                }
            } else {
                // Top - Bottom layout for portrait
                VStack(spacing: 0) {
                    ZStack(alignment: .top) {
                        question.backgroundColor
                            .edgesIgnoringSafeArea(.all)
                        
                        Text("問題 \(gameManager.currentQuestionIndex + 1) / 10")
                            .font(.headline)
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                            .padding(.top, 40)
                    }
                    
                    VStack(spacing: 15) {
                        Text("選擇最符合背景色的名稱：")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                        
                        ForEach(question.options) { option in
                            Button(action: {
                                gameManager.selectAnswer(option)
                            }) {
                                Text(option.name)
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .id(gameManager.currentQuestionIndex)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                }
            }
        }
    }
}