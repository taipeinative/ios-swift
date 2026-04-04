import SwiftUI

struct Heading: View {
    let visible: Bool

    var body: some View {
        HStack(spacing: 20) {
            // It might be a glitch, but Music's page title doesn't support DynamicType as of iOS 26.4
            Text("Library")
                .font(.system(size: 34))
                .fontWeight(.bold)
            
            Spacer()
            
            // Button sets
            HStack(spacing: 10) {
                Button(action: {}) {
                    Image(systemName: "text.badge.plus")
                }
                .padding(10)
                
                Menu() {
                    Button(action: {})
                    {
                        Label("Edit Sections", systemImage: "checklist")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }
                .padding(10)
            }
            .font(.system(size: 26))
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .capsule)
            .blur(radius: visible ? 0 : 10)
            
            AsyncImage(url: URL(string: "https://avatars.githubusercontent.com/u/85215798")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40)
            .clipShape(Circle())
            .blur(radius: visible ? 0 : 10)
            
        }
        .padding(.horizontal, 20)
        .opacity(visible ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: visible)
    }
}

struct DummyHeading: View {
    var body: some View {
        Rectangle()
            .frame(height: 40)
            .foregroundStyle(Color.clear)
            .listRowSeparator(.hidden)
    }
}
