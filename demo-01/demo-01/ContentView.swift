import SwiftUI

struct ContentView: View {
    @State private var currentPage: AppPage = .menu
    @State private var gameSettings = GameSettings()

    var body: some View {
        ZStack {
            PixelBackground()

            switch currentPage {
            case .menu:
                MenuView(
                    onOpenSettings: { currentPage = .settings },
                    onPlay: { currentPage = .stage }
                )
            case .settings:
                SettingsView(
                    settings: $gameSettings,
                    onBack: { currentPage = .menu }
                )
            case .stage:
                StageView(
                    settings: gameSettings,
                    onExit: { currentPage = .menu }
                )
            }
        }
        .preferredColorScheme(.dark)
    }
}

enum AppPage {
    case menu
    case settings
    case stage
}

struct MenuView: View {
    let onOpenSettings: () -> Void
    let onPlay: () -> Void

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 12) {
                Text("小小移民官")
                    .font(.system(size: 44, weight: .black, design: .monospaced))
                    .foregroundStyle(.yellow)
                Text("LOGO 佔位")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.35))
                    .overlay(
                        Rectangle()
                            .stroke(Color.white.opacity(0.8), lineWidth: 2)
                    )
            }

            Spacer()

            HStack(spacing: 20) {
                PixelButton(title: "設定", action: onOpenSettings)
                PixelButton(title: "遊玩", action: onPlay)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
    }
}

struct SettingsView: View {
    @Binding var settings: GameSettings
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("設定")
                    .font(.system(size: 32, weight: .black, design: .monospaced))
                Spacer()
                PixelButton(title: "返回", action: onBack)
                    .frame(width: 120)
            }

            PixelPanel(title: "音量") {
                HStack {
                    Slider(value: $settings.volume, in: 0...1)
                        .tint(.green)
                    Text("\(Int(settings.volume * 100))")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .frame(width: 42)
                }
            }

            PixelPanel(title: "難度") {
                HStack(spacing: 12) {
                    ForEach(Difficulty.allCases, id: \.self) { level in
                        Button {
                            settings.difficulty = level
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: settings.difficulty == level ? "largecircle.fill.circle" : "circle")
                                Text(level.title)
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(settings.difficulty == level ? Color.indigo.opacity(0.9) : Color.black.opacity(0.35))
                            .overlay(
                                Rectangle()
                                    .stroke(Color.white.opacity(0.8), lineWidth: 2)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            PixelPanel(title: "懲罰") {
                Button {
                    settings.penaltyEnabled.toggle()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: settings.penaltyEnabled ? "checkmark.square.fill" : "square")
                            .font(.system(size: 20, weight: .bold))
                        Text("啟用錯誤扣分")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                    }
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .padding(24)
    }
}

struct PixelBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color(red: 0.16, green: 0.19, blue: 0.21), Color(red: 0.22, green: 0.16, blue: 0.12)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

struct PixelPanel<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 22, weight: .black, design: .monospaced))
                .foregroundStyle(.yellow)
            content
        }
        .padding(16)
        .background(Color.black.opacity(0.35))
        .overlay(
            Rectangle()
                .stroke(Color.white.opacity(0.85), lineWidth: 2)
        )
    }
}

struct PixelButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 22, weight: .black, design: .monospaced))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.blue.opacity(0.75))
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.95), lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
