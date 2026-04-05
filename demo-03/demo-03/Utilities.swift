import Foundation
import AVFoundation
import Combine

struct Track: Codable, Identifiable {
    let id: String
    let title: String
    let artist: String
    let cover: String
    let src: String
}

// Loads the albums from the Albums.json file.
func loadAlbums() -> [Album] {
    guard let url = Bundle.main.url(forResource: "Albums", withExtension: "json") else {
        print("File not found in bundle")
        return []
    }

    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let albums = try decoder.decode([Album].self, from: data)
        return albums
    } catch {
        print("Failed to decode JSON: \(error)")
        return []
    }
}

// Loads the tracks from the Tracks.json file.
func loadTracks() -> [Track] {
    guard let url = Bundle.main.url(forResource: "Tracks", withExtension: "json") else {
        print("Tracks file not found in bundle")
        return []
    }

    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([Track].self, from: data)
    } catch {
        print("Failed to decode Tracks.json: \(error)")
        return []
    }
}

final class MusicPlayerService: ObservableObject {
    @Published private(set) var tracks: [Track]
    @Published private(set) var currentTrackIndex: Int = 0
    @Published private(set) var isPlaying: Bool = false

    private var player: AVPlayer?
    private var itemDidFinishObserver: NSObjectProtocol?

    var currentTrack: Track? {
        guard tracks.indices.contains(currentTrackIndex) else { return nil }
        return tracks[currentTrackIndex]
    }

    init(tracks: [Track] = loadTracks()) {
        self.tracks = tracks
        configureAudioSession()

        if !tracks.isEmpty {
            prepareTrack(at: 0)
        }
    }

    deinit {
        if let observer = itemDidFinishObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func setTracks(_ newTracks: [Track], autoplay: Bool = false) {
        tracks = newTracks
        currentTrackIndex = 0

        guard !tracks.isEmpty else {
            player?.pause()
            player = nil
            isPlaying = false
            return
        }

        prepareTrack(at: 0)
        if autoplay {
            play()
        }
    }

    func togglePlayPause() {
        isPlaying ? pause() : play()
    }

    func play() {
        guard let player else { return }
        player.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func playNextTrack() {
        guard !tracks.isEmpty else { return }
        let nextIndex = (currentTrackIndex + 1) % tracks.count
        playTrack(at: nextIndex, autoplay: isPlaying)
    }

    func playPreviousTrack() {
        guard !tracks.isEmpty else { return }
        let previousIndex = (currentTrackIndex - 1 + tracks.count) % tracks.count
        playTrack(at: previousIndex, autoplay: isPlaying)
    }

    func selectTrack(byID id: String, autoplay: Bool = true) {
        guard let index = tracks.firstIndex(where: { $0.id == id }) else { return }
        playTrack(at: index, autoplay: autoplay)
    }

    func playTrack(at index: Int, autoplay: Bool = true) {
        guard tracks.indices.contains(index) else { return }
        currentTrackIndex = index
        prepareTrack(at: index)

        if autoplay {
            play()
        }
    }

    private func prepareTrack(at index: Int) {
        guard tracks.indices.contains(index) else { return }
        guard let url = URL(string: tracks[index].src) else {
            print("Invalid track URL: \(tracks[index].src)")
            return
        }

        let item = AVPlayerItem(url: url)
        if player == nil {
            player = AVPlayer(playerItem: item)
        } else {
            player?.replaceCurrentItem(with: item)
        }

        observeCurrentItemFinished(item)
    }

    private func observeCurrentItemFinished(_ item: AVPlayerItem) {
        if let observer = itemDidFinishObserver {
            NotificationCenter.default.removeObserver(observer)
        }

        itemDidFinishObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.playTrack(at: (self.currentTrackIndex + 1) % self.tracks.count, autoplay: true)
        }
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.allowAirPlay])
            try session.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
}