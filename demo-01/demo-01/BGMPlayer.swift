import Combine
import Foundation
import AVFoundation
import UIKit

final class BGMPlayer: ObservableObject {
    static let shared = BGMPlayer()

    private var audioPlayer: AVAudioPlayer?
    private var hasPrepared = false
    private var audioData: Data?

    private init() {}

    func startLoopingIfAvailable() {
        if !hasPrepared {
            preparePlayer()
        }

        guard let audioPlayer else { return }
        if !audioPlayer.isPlaying {
            audioPlayer.play()
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        try? AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
    }

    private func preparePlayer() {
        hasPrepared = true

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)

            if let dataAsset = NSDataAsset(name: "bgm_loop") {
                audioData = dataAsset.data
                let player = try AVAudioPlayer(data: dataAsset.data)
                player.numberOfLoops = -1
                player.volume = 0.5
                player.prepareToPlay()
                audioPlayer = player
                return
            }

            let candidates = [
                ("bgm_loop", "mp3"),
                ("bgm_loop", "m4a"),
                ("bgm_loop", "wav")
            ]

            guard let url = candidates.compactMap({ Bundle.main.url(forResource: $0.0, withExtension: $0.1) }).first else {
                return
            }

            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 0.5
            player.prepareToPlay()
            audioPlayer = player
        } catch {
            audioPlayer = nil
        }
    }
}
