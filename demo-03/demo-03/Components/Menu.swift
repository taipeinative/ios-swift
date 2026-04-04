import SwiftUI

struct MenuBar<Content: View>: View {
    // Embedding view
    let libraryView: Content
    
    // Force the tab to Library (the last tab)
    @State private var selectedTab = 3
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab ("Home", systemImage: "house", value: 0) {}
            Tab ("New", systemImage: "square.grid.2x2.fill", value: 1) {}
            Tab ("Radio", systemImage: "dot.radiowaves.left.and.right", value: 2) {}
            Tab("Library", image: "music.square.stack.fill", value: 3) {
                libraryView
                    .tint(nil)
            }
        }
        .tint(.pink)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            NowPlaying()
                .padding(.horizontal, 20)
                .padding(.bottom, 55)
        }
    }
}

struct NowPlaying: View {
    @State private var playing: Bool = false
    
    var body: some View {
        HStack(spacing: 10) {
            AsyncImage(url: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Video211/v4/f0/ab/90/f0ab9038-7729-c0c7-3fe8-0aa061c54e32/Jobeb1f0cd2-7816-486a-b89d-a574a2d0ded0-190496666-PreviewImage_Preview_Image_Intermediate_nonvideo_373057617_2126449826-Time1744910399290.png/316x316bb.webp")) { image in
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 7))
            } placeholder: {
                ProgressView()
                    .aspectRatio(1, contentMode: .fit)
            }
            .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Photographs (feat. nokio)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text("Dabin")
                    .font(.caption)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button {
                playing = !playing
                print(playing ? "Now playing" : "Now pause")
            } label: {
                Image(systemName: playing ? "pause.fill" : "play.fill")
            }
            
            Button {
                print("Skip")
            } label: {
                Image(systemName: "forward.fill")
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .capsule)
    }
}

#Preview {
    MenuBar(libraryView: ContentView())
}
