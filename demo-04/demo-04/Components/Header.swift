import SwiftUI

struct Header: View {
    var title: String
    var small: Bool = false
    var serif: Bool = false
    
    var body: some View {
        HStack {
            Text(title)
                .font(serif ? .custom("Hiragino Mincho Pro", size: 34, relativeTo: .largeTitle) : small ? .title : .largeTitle)
                .fontWeight(small ? .medium : .bold)
            
            Spacer()
        }
        .padding([.bottom], 1)
    }
}
