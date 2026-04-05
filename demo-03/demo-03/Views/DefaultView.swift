import SwiftUI

struct DefaultView: View {
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Nothing to see here yet...")
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    DefaultView(title: "Default")
}
