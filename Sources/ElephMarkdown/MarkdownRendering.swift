import SwiftUI
import Markdown
import ElephThemes

// Using qualified names to avoid ambiguity
typealias MarkdownLink = Markdown.Link
typealias MarkdownBlockquote = Markdown.BlockQuote

// A custom markdown renderer to handle different elements
public class MarkdownRenderer {
    private let theme: Theme?
    
    public init(theme: Theme? = nil) {
        self.theme = theme
    }
    
    // In a real implementation, this would traverse all elements
    // and apply styling based on the theme
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

public struct MarkdownRendererView: View {
    private let markdown: String
    private let theme: Theme?
    private let parser: MarkdownParser
    
    @State private var attributedText: AttributedString?
    
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
                // Use the native AttributedString-based Markdown rendering
                Text(LocalizedStringKey(markdown))
                    .textSelection(.enabled)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                // Fallback for older systems
                markdownText
                    .textSelection(.enabled)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    @ViewBuilder
    private var markdownText: some View {
        VStack(alignment: .leading, spacing: 8) {
            let lines = markdown.components(separatedBy: "\n")
            
            ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                if line.starts(with: "#") {
                    headingView(for: line)
                } else if line.starts(with: "-") || line.starts(with: "*") {
                    bulletView(for: line)
                } else if line.starts(with: ">") {
                    quoteView(for: line)
                } else if line.contains("**") || line.contains("__") {
                    boldView(for: line)
                } else if line.contains("*") || line.contains("_") {
                    italicView(for: line)
                } else if !line.isEmpty {
                    Text(line)
                        .font(.body)
                } else {
                    Spacer()
                        .frame(height: 8)
                }
            }
        }
    }
    
    private func headingView(for line: String) -> some View {
        let level = line.prefix(while: { $0 == "#" }).count
        let text = line.dropFirst(level + 1)
        
        let font: Font = {
            switch level {
            case 1: return .system(size: 28, weight: .bold)
            case 2: return .system(size: 24, weight: .bold)
            case 3: return .system(size: 20, weight: .bold)
            case 4: return .system(size: 18, weight: .semibold)
            case 5: return .system(size: 16, weight: .semibold)
            default: return .system(size: 14, weight: .semibold)
            }
        }()
        
        return Text(String(text))
            .font(font)
            .foregroundColor(theme?.headingColor ?? .primary)
            .padding(.vertical, 4)
    }
    
    private func bulletView(for line: String) -> some View {
        let text = line.dropFirst(2)
        return HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.body)
            Text(String(text))
                .font(.body)
        }
    }
    
    private func quoteView(for line: String) -> some View {
        let text = line.dropFirst(2)
        return HStack {
            Rectangle()
                .fill(theme?.blockquoteBackground ?? Color.gray.opacity(0.3))
                .frame(width: 4)
            Text(String(text))
                .font(.body)
                .italic()
                .foregroundColor(theme?.blockquoteText ?? .secondary)
        }
        .padding(.leading, 8)
    }
    
    private func boldView(for line: String) -> some View {
        // This is a simplified approach, a real implementation would 
        // properly handle mixed formatting within a line
        if line.contains("**") {
            let parts = line.components(separatedBy: "**")
            return Text(parts.joined(separator: ""))
                .font(.body.bold())
        } else if line.contains("__") {
            let parts = line.components(separatedBy: "__")
            return Text(parts.joined(separator: ""))
                .font(.body.bold())
        } else {
            return Text(line)
                .font(.body)
        }
    }
    
    private func italicView(for line: String) -> some View {
        // This is a simplified approach, a real implementation would 
        // properly handle mixed formatting within a line
        if line.contains("*") && !line.contains("**") {
            let parts = line.components(separatedBy: "*")
            return Text(parts.joined(separator: ""))
                .font(.body.italic())
        } else if line.contains("_") && !line.contains("__") {
            let parts = line.components(separatedBy: "_")
            return Text(parts.joined(separator: ""))
                .font(.body.italic())
        } else {
            return Text(line)
                .font(.body)
        }
    }
}