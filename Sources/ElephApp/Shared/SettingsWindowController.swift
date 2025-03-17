import SwiftUI
import AppKit
import ElephThemes

#if os(macOS)
public class SettingsWindowController: NSWindowController {
    private var themeManager: ThemeManager
    private var settingsWindow: NSWindow?
    
    public init(themeManager: ThemeManager) {
        self.themeManager = themeManager
        super.init(window: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func showSettings() {
        if settingsWindow == nil {
            // Create the settings window if it doesn't exist
            let settingsView = ThemeSettingsView(themeManager: themeManager)
            let hostingController = NSHostingController(rootView: settingsView)
            
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 350, height: 250),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.title = "Settings"
            window.contentViewController = hostingController
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }
        
        // Show and activate the window
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
#endif
