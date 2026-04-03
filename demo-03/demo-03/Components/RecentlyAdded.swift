import SwiftUI

struct RecentlyAdded: View {
    let albums: [Album] = loadAlbums()
    let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recently Added")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(albums) { album in
                    AlbumItem(url: album.url, title: album.title, artist: album.artist)
                }
            }
        }
        .listRowBackground(Color.clear)
    }
}
