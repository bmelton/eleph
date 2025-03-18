import SwiftUI
import AppKit  // Added for NSWorkspace

struct LinkDemoView: View {
    @State private var linkSelection: URL?
    
    var body: some View {
        VStack {
            Text("Link Demo")
                .font(.headline)
            
            Link("Click this direct SwiftUI Link", destination: URL(string: "https://apple.com")!)
                .padding()
                .foregroundColor(.blue)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .padding(.bottom)
            
            Divider()
            
            // Our custom FormattedTextPane with links
            FormattedTextPane(textSegments: [
                ("This text contains a ", TextStyle.regular),
                ("clickable link ", TextStyle.hyperlink(url: URL(string: "https://www.apple.com")!)),
                ("to demonstrate how links work.", TextStyle.regular)
            ])
            .frame(height: 100)
            .border(Color.gray)
        }
        .padding()
    }
}

// Custom NSTextView wrapper to handle cursor changes for links
struct LinkTextView: NSViewRepresentable {
    var attributedString: AttributedString
    
    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.allowsUndo = false
        textView.textContainer?.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.backgroundColor = .clear
        
        // Setup link attributes detection
        textView.linkTextAttributes = [
            .foregroundColor: NSColor.linkColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .cursor: NSCursor.pointingHand
        ]
        
        return textView
    }
    
    func updateNSView(_ nsView: NSTextView, context: Context) {
        // Convert AttributedString to NSAttributedString
        let nsAttributedString = NSAttributedString(attributedString)
        nsView.textStorage?.setAttributedString(nsAttributedString)
        
        // Set cursor to pointing hand for link regions
        let linkRanges = getLinkRanges(from: nsAttributedString)
        for range in linkRanges {
            nsView.textStorage?.addAttribute(.cursor, value: NSCursor.pointingHand, range: range)
        }
    }
    
    // Helper method to find ranges of links in the attributed string
    private func getLinkRanges(from attrString: NSAttributedString) -> [NSRange] {
        var ranges: [NSRange] = []
        let fullRange = NSRange(location: 0, length: attrString.length)
        
        attrString.enumerateAttribute(.link, in: fullRange) { value, range, _ in
            if value != nil {
                ranges.append(range)
            }
        }
        
        return ranges
    }
}

// A style definition for text formatting
struct TextStyle {
    let fontWeight: Font.Weight
    let italic: Bool
    let color: Color
    let backgroundColor: Color?
    let underlined: Bool
    let link: URL?
    
    static let regular = TextStyle(
        fontWeight: .regular,
        italic: false,
        color: .primary,
        backgroundColor: nil,
        underlined: false,
        link: nil
    )
    
    static let bold = TextStyle(
        fontWeight: .bold,
        italic: false,
        color: .primary,
        backgroundColor: nil,
        underlined: false,
        link: nil
    )
    
    static let italic = TextStyle(
        fontWeight: .regular,
        italic: true,
        color: .primary,
        backgroundColor: nil,
        underlined: false,
        link: nil
    )
    
    static let boldItalic = TextStyle(
        fontWeight: .bold,
        italic: true,
        color: .primary,
        backgroundColor: nil,
        underlined: false,
        link: nil
    )
    
    static func hyperlink(url: URL) -> TextStyle {
        return TextStyle(
            fontWeight: .regular,
            italic: false,
            color: .blue,
            backgroundColor: nil,
            underlined: true,
            link: url
        )
    }
}

struct EditorPane: View {
    let text: String
    let fontWeight: Font.Weight
    let italic: Bool
    let color: Color
    let backgroundColor: Color?
    let underlined: Bool
    
    init(
        text: String,
        fontWeight: Font.Weight = .regular,
        italic: Bool = false,
        color: Color = .primary,
        backgroundColor: Color? = nil,
        underlined: Bool = false
    ) {
        self.text = text
        self.fontWeight = fontWeight
        self.italic = italic
        self.color = color
        self.backgroundColor = backgroundColor
        self.underlined = underlined
    }
    
    var body: some View {
        ScrollView {
            Text(text)
                .font(italic ? .body.italic().weight(fontWeight) : .body.weight(fontWeight))
                .foregroundColor(color)
                .padding(8)
                .background(backgroundColor)
                .underline(underlined)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(4)
    }
}

// A component to display multiple styled text segments
// A component to display multiple styled text segments
struct FormattedTextPane: View {
    let textSegments: [(String, TextStyle)]
    
    private var attributedString: AttributedString {
        var result = AttributedString("")
        
        for (text, style) in textSegments {
            var segment = AttributedString(text)
            segment.font = style.italic ? .body.italic().weight(style.fontWeight) : .body.weight(style.fontWeight)
            segment.foregroundColor = style.color
            
            if let bgColor = style.backgroundColor {
                segment.backgroundColor = bgColor
            }
            
            if style.underlined {
                segment.underlineStyle = Text.LineStyle.single
            }
            
            if let url = style.link {
                segment.link = url
            }
            
            result.append(segment)
        }
        
        return result
    }
    
    var body: some View {
        ScrollView {
            LinkTextView(attributedString: attributedString)
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(4)
    }
}


// Example usage - renamed to avoid conflicts with existing ContentView
struct EditorPaneExampleView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Simple Editor Pane")
                .font(.headline)
                .padding()
            
            EditorPane(
                text: "This is a simple editor pane with basic formatting.",
                fontWeight: .semibold,
                color: .blue
            )
            .frame(height: 100)
            .border(Color.gray)
            .padding(.horizontal)
            
            Text("Formatted Text Pane")
                .font(.headline)
            
            FormattedTextPane(textSegments: [
                ("This is bold text. ", TextStyle.bold),
                ("This is italic text. ", TextStyle.italic),
                ("This is both bold AND italic. ", TextStyle.boldItalic),
                ("This is colored text. ", TextStyle(fontWeight: .regular, italic: false, color: .blue, backgroundColor: nil, underlined: false, link: nil)),
                ("This has a background. ", TextStyle(fontWeight: .regular, italic: false, color: .primary, backgroundColor: Color.yellow, underlined: false, link: nil)),
                ("This is underlined.", TextStyle(fontWeight: .regular, italic: false, color: .primary, backgroundColor: nil, underlined: true, link: nil)),
                ("\nThis is a link to Apple's website. ", TextStyle.hyperlink(url: URL(string: "https://www.apple.com")!))
            ])
            .frame(height: 150)
            .border(Color.gray)
            .padding(.horizontal)
            
            Divider()
            
            // Add the link demo
            LinkDemoView()
        }
        .padding()
    }
}

// Preview for the example view
struct EditorPaneExampleView_Previews: PreviewProvider {
    static var previews: some View {
        EditorPaneExampleView()
    }
}


