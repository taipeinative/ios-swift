import SwiftUI

struct ButtonView: View {
    var body: some View {
        VStack {
            HStack {
                Button("Plain"){
                    print("This is a plain text button.")
                }
                .buttonStyle(.plain)
                
                Button("Borderless") {
                    print("This is a borderless button.")
                }
                Button("Bordered"){
                    print("This is a bordered button.")
                }
                .buttonStyle(.bordered)
            }
            .vSpacer(10)
            
            Button("Bordered Prominent Button"){
                print("This is a prominent bordered button.")
            }
            .buttonStyle(.borderedProminent)
            .buttonSizing(.flexible)            // Width 100%
            
        }
        .padding()
    }
}

#Preview {
    ButtonView()
}
