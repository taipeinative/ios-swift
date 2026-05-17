import SwiftUI

struct ModeButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}