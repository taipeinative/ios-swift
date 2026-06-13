import SwiftUI

struct IconButton: View {
    let systemName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.gray)
                .frame(width: 40, height: 40)
                .background(.quinary)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 20) {
        IconButton(systemName: "heart.fill") {
            print("Heart tapped")
        }
        
        IconButton(systemName: "message.fill") {
            print("Message tapped")
        }
        
        IconButton(systemName: "paperplane.fill") {
            print("Share tapped")
        }
    }
    .padding()
}
