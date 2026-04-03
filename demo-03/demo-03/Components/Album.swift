import SwiftUI

struct Album: Codable, Identifiable {
    var id: String
    let url: String
    let title: String
    let artist: String
}

struct AlbumItem: View {
    let url: String
    let title: String
    let artist: String
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
                ProgressView()
                    .aspectRatio(1, contentMode: .fit)
            }

            Text(title)
                .fontWeight(.medium)
                .lineLimit(1)

            Text(artist)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding([.bottom], 10)
    }
}
