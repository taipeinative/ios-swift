import SwiftUI

struct VSpacer: ViewModifier {
    var spacing: CGFloat
    func body(content: Content) -> some View {
        content
            .padding([.bottom], spacing)
    }
}

// Extension registery
extension View {
    func vSpacer(_ spacing: CGFloat = 5) -> some View {
        self.modifier(VSpacer(spacing: spacing))
    }
}
