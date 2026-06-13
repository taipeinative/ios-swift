import SwiftUI

struct SearchBarButton: View {
    let searchTerms = [
        "搜尋藝人、歌曲或專輯⋯⋯",
        "周杰倫",
        "稻香",
        "搜尋地點⋯⋯",
        "國立臺灣大學",
        "貳樓公館店",
        "搜尋電影或戲劇⋯⋯",
        "大賣空",
        "後宮甄嬛傳",
    ]
    
    @State private var displayedText = ""
    @State private var currentTermIndex = 0
    @State private var isDeleting = false
    @State private var characterIndex = 0
    
    let typingSpeed = 0.12
    let deletingSpeed = 0.05
    let pauseDuration = 2.0
    
    var body: some View {
        Button {
            // Action for when they tap the fake search bar
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.gray.quinary)
                    .frame(maxWidth: .infinity, maxHeight: 35)
                
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 12)
                    
                    Text(displayedText)
                        .lineLimit(1)
                        .foregroundStyle(.gray)
                    
                    CursorView()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
        .onAppear {
            runTypewriterLoop()
        }
    }
    
    private func runTypewriterLoop() {
        guard !searchTerms.isEmpty else { return }
        
        let currentFullText = searchTerms[currentTermIndex]
        
        if !isDeleting {
            // --- TYPING PHASE ---
            if characterIndex < currentFullText.count {
                // Add the next character
                let index = currentFullText.index(currentFullText.startIndex, offsetBy: characterIndex)
                displayedText.append(currentFullText[index])
                characterIndex += 1
                
                // Schedule next character write
                DispatchQueue.main.asyncAfter(deadline: .now() + typingSpeed) {
                    runTypewriterLoop()
                }
            } else {
                // Done typing! Pause at full length, then switch to deleting phase
                isDeleting = true
                DispatchQueue.main.asyncAfter(deadline: .now() + pauseDuration) {
                    runTypewriterLoop()
                }
            }
        } else {
            // --- DELETING PHASE ---
            if characterIndex > 0 {
                // Drop the last character
                displayedText.removeLast()
                characterIndex -= 1
                
                // Schedule next character delete
                DispatchQueue.main.asyncAfter(deadline: .now() + deletingSpeed) {
                    runTypewriterLoop()
                }
            } else {
                // Done deleting! Shift context parameters to the next word item
                isDeleting = false
                currentTermIndex = (currentTermIndex + 1) % searchTerms.count
                
                // Tiny pause before starting to type the brand new word
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    runTypewriterLoop()
                }
            }
        }
    }
}

struct CursorView: View {
    @State private var isVisible = true
    
    var body: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.7))
            .frame(width: 2, height: 16)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    isVisible.toggle()
                }
            }
    }
}

#Preview {
    SearchBarButton()
}
