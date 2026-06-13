import SwiftUI

struct Heading: View {
    @State var text: String
    
    var body: some View {
        Text(text)
            .font(.largeTitle)
            .fontWeight(.medium)
    }
}

struct SubHeading: View {
    @State var text: String
    var isProminent: Bool = true
    
    var body: some View {
        Text(text)
            .font(isProminent ? .title2 : .title3)
            .fontWeight(isProminent ? .semibold : .medium)
            .foregroundStyle(isProminent ? AnyShapeStyle(.primary) : AnyShapeStyle(.primary.opacity(0.6)))
    }
}

#Preview {
    VStack {
        Heading(text: "大標題")
        SubHeading(text: "中標題")
        SubHeading(text: "中小標題", isProminent: false)
    }
}
