import SwiftUI
import Combine

public class ThemeManager: ObservableObject {
    @Published public var currentTheme: Theme
    @Published public private(set) var availableThemes: [Theme]
    @Published public var useDarkMode: Bool {
        didSet {
            updateThemeForAppearance()
            // Save user preference only if not using system appearance
            if !isUsingSystemAppearance {
                UserDefaults.standard.set(useDarkMode, forKey: "useDarkMode")
            }
        }
    }
    
    @Published public var isUsingSystemAppearance: Bool = false
    
    @Published public var selectedThemeId: String {
        didSet {
            updateThemeForAppearance()
            // Save user preference
            UserDefaults.standard.set(selectedThemeId, forKey: "selectedThemeId")
        }
    }
    
    public init() {
        // Default themes
        let defaultThemes: [Theme] = [
            ClassicTheme.light,
            MinimalTheme.light,
        ]
        
        // Initialize properties first before any logic
        self.availableThemes = defaultThemes
        self.selectedThemeId = UserDefaults.standard.string(forKey: "selectedThemeId") ?? ClassicTheme.light.id
        
        // Initialize with default values before any conditional logic
        self.useDarkMode = false
        self.currentTheme = ClassicTheme.light
        
        // Handle system appearance detection
        self.detectAndApplySystemAppearance()
        
        // Setup system appearance observer
        setupAppearanceObserver()
    }
    
    private func detectAndApplySystemAppearance() {
        // Check if user has explicitly set dark mode preference
        if UserDefaults.standard.object(forKey: "useDarkMode") != nil {
            self.useDarkMode = UserDefaults.standard.bool(forKey: "useDarkMode")
            self.isUsingSystemAppearance = false
        } else {
            // Use system appearance if no user preference exists
            #if os(macOS)
            if #available(macOS 12.0, *) {
                self.useDarkMode = NSApp.effectiveAppearance.name == .darkAqua
            } else {
                // Fallback for older macOS versions
                self.useDarkMode = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            }
            #else
            self.useDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
            #endif
            self.isUsingSystemAppearance = true
        }
        
        // Update the theme based on the dark mode setting
        updateThemeForAppearance()
    }
    
    private func setupAppearanceObserver() {
        #if os(macOS)
        // Create observer for appearance changes in macOS
        // Listen for effectiveAppearance changes on the shared application
        NotificationCenter.default.addObserver(
            self, 
            selector: #selector(systemAppearanceChanged),
            name: NSApplication.didChangeScreenParametersNotification, 
            object: nil
        )
        
        // Also listen for system appearance changes
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(systemAppearanceChanged),
            name: Notification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil
        )
        #endif
    }
    
    #if os(macOS)
    @objc private func systemAppearanceChanged() {
        // Only update if user hasn't explicitly set a preference
        if UserDefaults.standard.object(forKey: "useDarkMode") == nil {
            let isDark: Bool
            if #available(macOS 12.0, *) {
                isDark = NSApp.effectiveAppearance.name == .darkAqua
            } else {
                isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            }
            
            if self.useDarkMode != isDark {
                // Temporarily disable the property observer to avoid setting the preference
                // while we're just following the system
                let oldValue = isUsingSystemAppearance
                isUsingSystemAppearance = true
                self.useDarkMode = isDark
                // Do not save to UserDefaults here, as we're following system preference
                
                // Re-enable notification for future changes
                if oldValue != isUsingSystemAppearance {
                    self.objectWillChange.send()
                }
            }
        }
    }
    #endif
    
    public func selectTheme(id: String) {
        guard availableThemes.contains(where: { $0.id == id }) else {
            return
        }
        
        selectedThemeId = id
    }
    
    public func addTheme(_ theme: Theme) {
        if !availableThemes.contains(where: { $0.id == theme.id }) {
            availableThemes.append(theme)
        }
    }
    
    private func updateThemeForAppearance() {
        guard let baseTheme = availableThemes.first(where: { $0.id == selectedThemeId }) else {
            return
        }
        
        currentTheme = useDarkMode ? baseTheme.darkVariant : baseTheme.lightVariant
    }
}