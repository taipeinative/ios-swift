import SwiftData
import SwiftUI

@main
struct FinalApp: App {
    @AppStorage("appTheme") private var appThemeRawValue = ThemeOption.system.rawValue

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(ThemeOption(rawValue: appThemeRawValue)?.colorScheme)
        }
        .modelContainer(for: [Target.self, Review.self])
    }
}

#Preview {
    RootView()
}
