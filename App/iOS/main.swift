import SwiftUI
import ElephApp
import ElephCore
import ElephMarkdown
import ElephThemes

struct ElephApp: App {
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(themeManager)
        }
    }
}

// Entry point for iOS app
ElephApp.main()