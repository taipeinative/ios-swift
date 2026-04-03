import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                Heading()
                
                List {
                    SectionItem(title: "Playlists", icon: "music.note.list")
                    SectionItem(title: "Artists", icon: "music.microphone")
                    SectionItem(title: "Albums", icon: "square.stack")
                    SectionItem(title: "Genres", icon: "guitars")
                    SectionItem(title: "Songs", icon: "music.note")
                    SectionItem(title: "Downloaded", icon: "arrow.down.circle")
                    RecentlyAdded()
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .background(Color.clear)
            }
            .padding(.horizontal, 10)
            .toolbar(.hidden, for: .navigationBar)
        }
        .padding(0)
    }
}

#Preview {
    ContentView()
}
