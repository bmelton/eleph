import SwiftUI
import WebKit
import Markdown
import ElephThemes
import Foundation

// Using qualified names to avoid ambiguity
typealias MarkdownLink = Markdown.Link
typealias MarkdownBlockquote = Markdown.BlockQuote

// A custom markdown renderer to handle different elements
/*
public class MarkdownRenderer {
    private let theme: Theme?
    
    public init(theme: Theme? = nil) {
        self.theme = theme
    }
    
    // In a real implementation, this would traverse all elements
    // and apply styling based on the theme
}
*/
public class MarkdownRenderer {
    private let theme: Theme?

    public init(theme: Theme? = nil) {
        self.theme = theme
    }

    public func render(document: Document) -> AttributedString {
        return renderBlockChildren(Array(document.blockChildren))
    }

    private func renderBlockChildren(_ blocks: [BlockMarkup]) -> AttributedString {
        var result = AttributedString()
        for block in blocks {
            result += renderBlock(block)
        }
        return result
    }

    private func renderBlock(_ block: BlockMarkup) -> AttributedString {
        switch block {
        case let heading as Heading:
            return renderHeading(heading)
        case let paragraph as Paragraph:
            return renderParagraph(paragraph)
        case let blockquote as BlockQuote:
            return renderBlockquote(blockquote)
        // Add more cases for other block types
        default:
            return AttributedString(block.debugDescription())
        }
    }

    private func renderHeading(_ heading: Heading) -> AttributedString {
        var container = AttributeContainer()
        //Apply styling from theme.
        if let theme = theme {
            container.foregroundColor = theme.headingColor
        }
        switch heading.level {
        case 1:
            container.font = .system(size: 28, weight: .bold)
        case 2:
            container.font = .system(size: 24, weight: .bold)
        //Add the rest of the cases.
        default:
            container.font = .system(size: 16, weight: .bold)
        }
        var result = renderInlineChildren(Array(heading.inlineChildren)) // Changed to var
        result.mergeAttributes(container, mergePolicy: .keepNew)
        return result
    }
    
    private func renderParagraph(_ paragraph: Paragraph) -> AttributedString {
        let result = renderInlineChildren(Array(paragraph.inlineChildren))
        return result + AttributedString("\n")
    }

    private func renderInlineChildren(_ inlines: [InlineMarkup]) -> AttributedString {
        var result = AttributedString()
        for inline in inlines {
            result += renderInline(inline)
        }
        return result
    }

    private func renderInline(_ inline: InlineMarkup) -> AttributedString {
        switch inline {
        case let text as Markdown.Text: // Explicitly use Markdown.Text
            return AttributedString(text.string)
        case let link as Markdown.Link: // Explicitly use Markdown.Link
            return renderLink(link)
        case let code as InlineCode:
            return renderCode(code)
        // Add more cases for other inline types
        default:
            return AttributedString(inline.debugDescription()) // Fallback
        }
    }

    private func renderLink(_ link: Markdown.Link) -> AttributedString {
        var container = AttributeContainer()
        if let theme = theme {
            container.foregroundColor = theme.linkColor
        }
        if let url = URL(string: link.destination ?? "") {
            container.link = url
        }
        var result = renderInlineChildren(Array(link.inlineChildren))
        result.mergeAttributes(container, mergePolicy: .keepNew)
        return result
    }
    
    private func renderCode(_ code: InlineCode) -> AttributedString {
        var container = AttributeContainer()
        container.font = .system(.body, design: .monospaced)
        if let theme = theme {
            container.backgroundColor = theme.codeBackground
            container.foregroundColor = theme.codeText
        } else {
            container.backgroundColor = Color(white: 0.95)
        }
        var result = AttributedString(code.code)
        result.mergeAttributes(container, mergePolicy: .keepNew)
        return result
    }

    private func renderBlockquote(_ blockquote: BlockQuote) -> AttributedString {
        var container = AttributeContainer()
        if let theme = theme {
            container.backgroundColor = theme.blockquoteBackground
            container.foregroundColor = theme.blockquoteText
        } else {
            container.backgroundColor = Color(white: 0.95)
        }
        var result = renderBlockChildren(Array(blockquote.blockChildren))
        result.mergeAttributes(container, mergePolicy: .keepNew)
        return result;
    }
}

// This extension provides helper methods to style the markdown elements
// based on the current theme
extension MarkdownRenderer {
    func styleHeading(_ heading: Heading) -> AttributeContainer {
        var container = AttributeContainer()
        
        // Set font size based on heading level
        switch heading.level {
        case 1:
            container.font = .system(size: 28, weight: .bold)
        case 2:
            container.font = .system(size: 24, weight: .bold)
        case 3:
            container.font = .system(size: 20, weight: .bold)
        case 4:
            container.font = .system(size: 18, weight: .semibold)
        case 5:
            container.font = .system(size: 16, weight: .semibold)
        case 6:
            container.font = .system(size: 14, weight: .semibold)
        default:
            container.font = .system(size: 16, weight: .regular)
        }
        
        if let theme = theme {
            container.foregroundColor = theme.headingColor
        }
        
        return container
    }
    
    func styleLink(_ link: MarkdownLink) -> AttributeContainer {
        var container = AttributeContainer()
        
        if let theme = theme {
            container.foregroundColor = theme.linkColor
        } else {
            container.foregroundColor = .blue
        }
        
        // Store the URL for handling taps later
        if let url = URL(string: link.destination ?? "") {
            container.link = url
        }
        
        return container
    }
    
    func styleCode(_ code: InlineCode) -> AttributeContainer {
        var container = AttributeContainer()
        
        container.font = .system(.body, design: .monospaced)
        
        if let theme = theme {
            container.backgroundColor = theme.codeBackground
            container.foregroundColor = theme.codeText
        } else {
            container.backgroundColor = Color(white: 0.95)
        }
        
        return container
    }
    
    func styleBlockquote(_ blockquote: MarkdownBlockquote) -> AttributeContainer {
        var container = AttributeContainer()
        
        if let theme = theme {
            container.backgroundColor = theme.blockquoteBackground
            container.foregroundColor = theme.blockquoteText
        } else {
            container.backgroundColor = Color(white: 0.95)
            container.foregroundColor = Color(white: 0.3)
        }
        
        return container
    }
}

import SwiftUI
import WebKit

public struct MarkdownRendererView: View {
    private let markdown: String
    private let theme: Theme?
    private let parser: MarkdownParser

    public init(
        markdown: String,
        specification: MarkdownSpecification = .commonMark,
        theme: Theme? = nil
    ) {
        self.markdown = markdown
        self.theme = theme
        self.parser = MarkdownParser(specification: specification)
    }

    public var body: some View {
        ScrollView {
            if #available(macOS 12.0, iOS 15.0, *) {
                let htmlString = parser.toHTML(markdown: markdown)
                WebView(htmlString: htmlString)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding() // Apply padding to the WebView's container, not WebView itself.
            } else {
                Text("Markdown rendering not supported on this OS version.")
            }
        }
    }
}

// Create separate WebView implementations for iOS and macOS
#if os(iOS)
struct WebView: UIViewRepresentable {
    let htmlString: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}
#elseif os(macOS)
struct WebView: NSViewRepresentable {
    let htmlString: String

    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(htmlString, baseURL: nil)
    }
}
#endif
