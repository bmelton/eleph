import SwiftUI
import AppKit
import ElephApp
import ElephCore
import ElephMarkdown
import ElephThemes

struct ElephMacApp: App {
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(themeManager)
                .frame(minWidth: 1000, minHeight: 600)
                .onAppear {
                    // Set app name
                    ProcessInfo.processInfo.processName = "Eleph"
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            // Add standard macOS menu commands
            CommandGroup(replacing: .newItem) {
                Button("New Document") {
                    // Add your new document action here
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandGroup(replacing: .help) {
                Button("Eleph Help") {
                    // Add your help action here
                }
            }
        }
    }
}

// Entry point for macOS app
ElephMacApp.main()