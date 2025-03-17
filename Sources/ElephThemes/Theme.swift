import SwiftUI

public protocol Theme {
    var id: String { get }
    var name: String { get }
    
    // Basic colors
    var background: Color { get }
    var foreground: Color { get }
    var accent: Color { get }
    
    // Text colors
    var primaryText: Color { get }
    var secondaryText: Color { get }
    var tertiaryText: Color { get }
    
    // UI element colors
    var navigationBackground: Color { get }
    var previewBackground: Color { get }
    var editorBackground: Color { get }
    var toolbarBackground: Color { get }
    
    // Markdown-specific colors
    var headingColor: Color { get }
    var linkColor: Color { get }
    var codeBackground: Color { get }
    var codeText: Color { get }
    var blockquoteBackground: Color { get }
    var blockquoteText: Color { get }
    
    // Returns the dark mode variant of this theme
    var darkVariant: Theme { get }
    
    // Returns the light mode variant of this theme
    var lightVariant: Theme { get }
    
    // Whether this theme is dark or light
    var isDark: Bool { get }
}

// Extension for applying themes to views
public extension View {
    func applyTheme(_ theme: Theme) -> some View {
        self.preferredColorScheme(theme.isDark ? .dark : .light)
            .accentColor(theme.accent)
            .foregroundColor(theme.primaryText)
            .background(theme.background)
    }
}