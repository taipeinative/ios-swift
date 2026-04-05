import SwiftUI

struct NowPlaying: View {
    let inLightMode: Bool
    @EnvironmentObject private var player: MusicPlayerService

    private var currentTrack: Track? {
        player.currentTrack
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Group {
                if let cover = currentTrack?.cover {
                    Image(cover)
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                } else {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "music.note")
                                .foregroundStyle(.secondary)
                        }
                }
            }
            .frame(width: 30)
            .padding([.trailing], 10)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(currentTrack?.title ?? "No Track")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(currentTrack?.artist ?? "Unknown Artist")
                    .font(.caption)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button {
                player.togglePlayPause()
            } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
            
            Button {
                player.playNextTrack()
            } label: {
                Image(systemName: "forward.fill")
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
        }
        .foregroundColor(inLightMode ? .black : .primary)
        .tint(inLightMode ? .black : .primary)
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }
}
