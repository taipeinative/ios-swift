import SwiftUI

struct Greeting: View {
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
        Heading(text: greeting)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    Greeting()
}
