import SwiftUI

struct SectionItem: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Label() {
                Text(title)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(.pink)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .listRowBackground(Color.clear)
    }
}
