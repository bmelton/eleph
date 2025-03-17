import SwiftUI
import AppKit
import ElephApp
import ElephCore
import ElephMarkdown
import ElephThemes

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    let themeManager = ThemeManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize the app here
        NSApplication.shared.setActivationPolicy(.regular) // Show in Dock

        // Create the SwiftUI view
        let contentView = MainView()
            .environmentObject(themeManager)

        // Create the window and set the content view
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)

        // Set app name
        ProcessInfo.processInfo.processName = "Eleph"

        self.window = window
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

// Entry Point
let delegate = AppDelegate()
NSApplication.shared.delegate = delegate
NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
