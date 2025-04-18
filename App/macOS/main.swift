import SwiftUI
import AppKit
import ElephApp
import ElephCore
import ElephMarkdown
import ElephThemes

class AppDelegate: NSObject, NSApplicationDelegate {
    var settingsWindowController: SettingsWindowController?
    private let tagsAndFoldersStorage = TagsAndFoldersStorage()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize the tags and folders storage on app start
        tagsAndFoldersStorage.initialize()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Force save documents before app terminates
        NotificationCenter.default.post(name: NSNotification.Name("SaveAllDocuments"), object: nil)
    }
    
    func setupSettingsController(with themeManager: ThemeManager) {
        settingsWindowController = SettingsWindowController(themeManager: themeManager)
    }
    
    func showSettings() {
        settingsWindowController?.showSettings()
    }
}

struct ElephMacApp: App {
    @StateObject private var themeManager = ThemeManager()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(themeManager)
                .frame(minWidth: 1000, minHeight: 600)
                .onAppear {
                    // Set app name
                    ProcessInfo.processInfo.processName = "Eleph"
                    // Set up settings controller
                    appDelegate.setupSettingsController(with: themeManager)
                }
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            // Add standard macOS menu commands
            CommandGroup(replacing: .newItem) {
                Button("New Document") {
                    // Create a new document and notify to refresh
                    let _ = Document.createNewDocument()
                    NotificationCenter.default.post(name: NSNotification.Name("RefreshDocumentsList"), object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            // Add preferences menu
            CommandGroup(replacing: .appSettings) {
                Button("Settings") {
                    appDelegate.showSettings()
                }
                .keyboardShortcut(",", modifiers: .command)
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
