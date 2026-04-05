import SwiftUI

struct NowPlaying: View {
    let inLightMode: Bool
    @State private var playing: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
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
            .padding([.trailing], 10)
            
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
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
            
            Button {
                print("Skip")
            } label: {
                Image(systemName: "forward.fill")
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
        }
        .foregroundColor(inLightMode ? .black : .primary)
        .tint(inLightMode ? .black : .primary)
        .buttonStyle(.plain)
    }
}
