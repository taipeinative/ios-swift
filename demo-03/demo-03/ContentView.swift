import SwiftUI

struct ContentView: View {
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    DummyHeading()
                    SectionItem(title: "Playlists", icon: "music.note.list")
                    SectionItem(title: "Artists", icon: "music.microphone")
                    SectionItem(title: "Albums", icon: "square.stack")
                    SectionItem(title: "Genres", icon: "guitars")
                    SectionItem(title: "Songs", icon: "music.note")
                    SectionItem(title: "Downloaded", icon: "arrow.down.circle")
                    RecentlyAdded()
                }
                .listStyle(.plain)
                .background(Color.clear)
                
                // Polyfill the header animation by tracking the scroll offset
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y + geometry.contentInsets.top
                } action: { _, newValue in
                    scrollOffset = max(0, newValue)
                }
            }
            .padding(.horizontal, 10)
            .overlay(alignment: .top) {
                Heading(visible: scrollOffset < 5)
            }
        }
    }
}

#Preview {
    MenuBar(libraryView: ContentView())
}
