import SwiftUI
import ElephApp
import ElephCore
import ElephMarkdown
import ElephThemes
import ElephCore.Storage

struct ElephApp: App {
    @StateObject private var themeManager = ThemeManager()
    private let tagsAndFoldersStorage = TagsAndFoldersStorage()
    
    init() {
        // Initialize the tags and folders storage on app start
        tagsAndFoldersStorage.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(themeManager)
        }
    }
}

// Entry point for iOS app
ElephApp.main()