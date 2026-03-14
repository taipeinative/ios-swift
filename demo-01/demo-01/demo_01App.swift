import SwiftUI

@main
struct demo_01App: App {
    @StateObject private var bgmPlayer = BGMPlayer.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    bgmPlayer.startLoopingIfAvailable()
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                bgmPlayer.startLoopingIfAvailable()
            case .inactive, .background:
                bgmPlayer.stopPlayback()
            @unknown default:
                break
            }
        }
    }
}
