import SwiftUI

struct Heading: View {
    var body: some View {
        HStack(spacing: 20) {
            // It might be a glitch, but Music's page title doesn't support DynamicType as of iOS 26.4
            Text("Library")
                .font(.system(size: 34))
                .fontWeight(.bold)
            
            Spacer()
            
            //
            HStack {
                Button(action: {}) {
                    Image(systemName: "text.badge.plus")
                        .padding([.trailing], 20)
                    
                    Image(systemName: "ellipsis")
                }
            }
            .font(.system(size: 26))
            .buttonStyle(.glass)
            
            AsyncImage(url: URL(string: "https://avatars.githubusercontent.com/u/85215798")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 40)
            .clipShape(Circle())
            
        }
        .padding(.horizontal, 20)
    }
}

#Preview() {
    ZStack {
        Heading()
    }
}
