import SwiftUI

// A classic theme with blue accent
public struct ClassicTheme: Theme {
    public let id: String
    public let name: String
    public let background: Color
    public let foreground: Color
    public let accent: Color
    public let primaryText: Color
    public let secondaryText: Color
    public let tertiaryText: Color
    public let navigationBackground: Color
    public let previewBackground: Color
    public let editorBackground: Color
    public let toolbarBackground: Color
    public let headingColor: Color
    public let linkColor: Color
    public let codeBackground: Color
    public let codeText: Color
    public let blockquoteBackground: Color
    public let blockquoteText: Color
    public let isDark: Bool
    
    public static let light = ClassicTheme(
        id: "classic-light",
        name: "Classic",
        background: Color(white: 1.0),
        foreground: Color(white: 0.1),
        accent: Color.blue,
        primaryText: Color(white: 0.1),
        secondaryText: Color(white: 0.3),
        tertiaryText: Color(white: 0.5),
        navigationBackground: Color(white: 0.95),
        previewBackground: Color(white: 1.0),
        editorBackground: Color(white: 1.0),
        toolbarBackground: Color(white: 0.95),
        headingColor: Color.blue,
        linkColor: Color.blue,
        codeBackground: Color(white: 0.95),
        codeText: Color(white: 0.1),
        blockquoteBackground: Color(white: 0.95),
        blockquoteText: Color(white: 0.3),
        isDark: false
    )
    
    public static let dark = ClassicTheme(
        id: "classic-dark",
        name: "Classic Dark",
        background: Color(white: 0.1),
        foreground: Color(white: 0.9),
        accent: Color.blue,
        primaryText: Color(white: 0.9),
        secondaryText: Color(white: 0.7),
        tertiaryText: Color(white: 0.5),
        navigationBackground: Color(white: 0.15),
        previewBackground: Color(white: 0.1),
        editorBackground: Color(white: 0.1),
        toolbarBackground: Color(white: 0.15),
        headingColor: Color.blue,
        linkColor: Color.blue,
        codeBackground: Color(white: 0.2),
        codeText: Color(white: 0.9),
        blockquoteBackground: Color(white: 0.2),
        blockquoteText: Color(white: 0.7),
        isDark: true
    )
    
    public var darkVariant: Theme {
        ClassicTheme.dark
    }
    
    public var lightVariant: Theme {
        ClassicTheme.light
    }
}

// A minimal theme with green accent
public struct MinimalTheme: Theme {
    public let id: String
    public let name: String
    public let background: Color
    public let foreground: Color
    public let accent: Color
    public let primaryText: Color
    public let secondaryText: Color
    public let tertiaryText: Color
    public let navigationBackground: Color
    public let previewBackground: Color
    public let editorBackground: Color
    public let toolbarBackground: Color
    public let headingColor: Color
    public let linkColor: Color
    public let codeBackground: Color
    public let codeText: Color
    public let blockquoteBackground: Color
    public let blockquoteText: Color
    public let isDark: Bool
    
    public static let light = MinimalTheme(
        id: "minimal-light",
        name: "Minimal",
        background: Color.white,
        foreground: Color.black,
        accent: Color.green,
        primaryText: Color.black,
        secondaryText: Color.gray,
        tertiaryText: Color.gray.opacity(0.7),
        navigationBackground: Color.white,
        previewBackground: Color.white,
        editorBackground: Color.white,
        toolbarBackground: Color.white,
        headingColor: Color.black,
        linkColor: Color.green,
        codeBackground: Color.gray.opacity(0.1),
        codeText: Color.black,
        blockquoteBackground: Color.gray.opacity(0.1),
        blockquoteText: Color.gray,
        isDark: false
    )
    
    public static let dark = MinimalTheme(
        id: "minimal-dark",
        name: "Minimal Dark",
        background: Color.black,
        foreground: Color.white,
        accent: Color.green,
        primaryText: Color.white,
        secondaryText: Color.gray,
        tertiaryText: Color.gray.opacity(0.7),
        navigationBackground: Color.black,
        previewBackground: Color.black,
        editorBackground: Color.black,
        toolbarBackground: Color.black,
        headingColor: Color.white,
        linkColor: Color.green,
        codeBackground: Color.gray.opacity(0.3),
        codeText: Color.white,
        blockquoteBackground: Color.gray.opacity(0.3),
        blockquoteText: Color.gray,
        isDark: true
    )
    
    public var darkVariant: Theme {
        MinimalTheme.dark
    }
    
    public var lightVariant: Theme {
        MinimalTheme.light
    }
}