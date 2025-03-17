import SwiftUI
import ElephThemes

public struct ThemeSettingsView: View {
    @ObservedObject var themeManager: ThemeManager
    @Environment(\.colorScheme) var systemColorScheme
    
    public init(themeManager: ThemeManager) {
        self.themeManager = themeManager
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Theme Settings")
                .font(.headline)
            
            Divider()
            
            // Dark Mode Settings
            VStack(spacing: 12) {
                HStack {
                    Toggle("Dark Mode", isOn: Binding(
                        get: { self.themeManager.useDarkMode },
                        set: { 
                            // When user explicitly sets this, we're no longer using system appearance
                            self.themeManager.isUsingSystemAppearance = false
                            self.themeManager.useDarkMode = $0
                        }
                    ))
                    .toggleStyle(.switch)
                    
                    Spacer()
                    
                    Image(systemName: themeManager.useDarkMode ? "moon.fill" : "sun.max.fill")
                        .foregroundColor(themeManager.useDarkMode ? .yellow.opacity(0.8) : .yellow)
                }
                
                // Option to follow system appearance
                HStack {
                    if themeManager.isUsingSystemAppearance {
                        Text("Following system appearance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Button("Use System Appearance") {
                            // Remove user preference to default to system appearance
                            UserDefaults.standard.removeObject(forKey: "useDarkMode")
                            
                            // Set the current appearance to match system
                            #if os(macOS)
                            let isDark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                            #else
                            let isDark = UITraitCollection.current.userInterfaceStyle == .dark
                            #endif
                            
                            // Update the UI to reflect the system appearance
                            themeManager.isUsingSystemAppearance = true
                            themeManager.useDarkMode = isDark
                        }
                        .font(.caption)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
            }
            
            // Theme Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Select Theme")
                    .font(.subheadline)
                
                Picker("Theme", selection: $themeManager.selectedThemeId) {
                    Text("Classic").tag("classic-light")
                    Text("Minimal").tag("minimal-light")
                }
                .pickerStyle(.segmented)
                
                // Preview of current theme
                HStack(spacing: 8) {
                    Circle()
                        .fill(themeManager.currentTheme.accent)
                        .frame(width: 16, height: 16)
                    
                    Text("Current theme: \(themeManager.currentTheme.name)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
