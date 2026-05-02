import SwiftUI

struct HomeView: View {
    @State private var selectedLink: Link?
    @State private var presentedLink: Link?

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6..<12:
            return "早安"
        case 12..<18:
            return "午安"
        default:
            return "晚安"
        }
    }
    
    var body: some View {
        Group {
            ScrollView {
                VStack(spacing: 8) {
                    Header(title: greeting, serif: true)
                    
                    Divider()
                        .padding(.bottom, 10)

                    OnThisDayBlock()

                    Header(title: "你知道嗎？", small: true)
                    ForEach(Array(DoYouKnowData.enumerated()), id: \.offset) { index, item in
                        Button {
                            handleLinkTap(for: item)
                        } label: {
                            HStack(alignment: .top) {
                                Text("\(index + 1).")
                                    .foregroundStyle(.secondary)

                                Text(questionText(for: item))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil)

                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    
                    FAGABlock()

                }
                .padding(.horizontal, 20)
            }
            
            // Detect user's tap to hide the widget
            .simultaneousGesture(
                TapGesture().onEnded {
                    if selectedLink != nil {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                            selectedLink = nil
                        }
                    }
                }
            )
        }
        
        // Answer widget of Do You Know?
        .safeAreaInset(edge: .bottom) {
            if let selectedLink {
                Button {
                    presentedLink = selectedLink
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "link")
                            .font(.headline)
                            .foregroundStyle(.blue)

                        Text(selectedLink.text)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .capsule)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.86), value: selectedLink?.url)
        
        // The web page to the Do You Know answer.
        .sheet(item: $presentedLink) { link in
            NavigationStack {
                LinkHelper(url: URL(string: link.url)!)
                    .ignoresSafeArea()
                    .navigationTitle(link.text)
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private func questionText(for item: DoYouKnow) -> AttributedString {
        var text = AttributedString(item.question)

        if let range = text.range(of: item.keyword) {
            text[range].foregroundColor = .accentColor
            text[range].font = .body.bold()
        }

        return text
    }

    private func handleLinkTap(for item: DoYouKnow) {
        let link = Link(text: item.answer, url: item.answerURL)

        if selectedLink?.url != link.url {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                selectedLink = link
            }
        }
    }
}

#Preview {
    HomeView()
}
