import SwiftUI

struct LinkGrocery: View {
    @State var links: [String: URL?]

    init(_ links: [String: URL?]) {
        self._links = State(initialValue: links)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(links.keys.sorted(), id: \.self) { key in
                if let url = links[key], let nonOptionalURL = url {
                    Link(destination: nonOptionalURL) {
                        Text(key)
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(key)
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

#Preview {
    LinkGrocery([
        "官方網站": URL(string: "https://example.com"),
        "維基百科": URL(string: "https://en.wikipedia.org/wiki/Example"),
        "相關討論": nil
    ])
}
