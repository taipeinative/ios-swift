import SwiftUI

struct Level: View {
    @State var level: Int

    init(_ level: Int) {
        self._level = State(initialValue: level)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 5) {
            Text("\(level)")
                .font(.largeTitle)
                .fontWeight(.medium)
            
            Text("級")
                .font(.title2)
        }
        .foregroundStyle(.blue)
    }
}

#Preview {
    @Previewable @State var level: Int = 15
    Level(level)
}
