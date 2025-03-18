import Foundation
import Markdown
import ElephThemes

public enum MarkdownSpecification {
    case commonMark
    case githubFlavored
    case pandoc
    // Can add more specifications in the future
}

public class MarkdownParser {
    private let specification: MarkdownSpecification

    public init(specification: MarkdownSpecification = .commonMark) {
        self.specification = specification
    }

    // Parse markdown text into a Document object
    public func parse(_ markdown: String) -> Document {
        let document = Document(parsing: markdown)
        return document
    }

    // Convert markdown to attributed string for rendering
    public func toAttributedString(markdown: String, theme: Theme? = nil) -> AttributedString {
        let document = parse(markdown)
        let renderer = MarkdownRenderer(theme: theme)
        return renderer.render(document: document)
    }

    // Convert markdown to HTML
    public func toHTML(markdown: String) -> String {
        let document = parse(markdown) // Parse the Markdown

        var html = "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><title></title></head><body>"

        for block in document.blockChildren {
            switch block {
            case let paragraph as Paragraph:
                html += "<p>"
                for inline in paragraph.inlineChildren {
                    switch inline {
                    case let text as Markdown.Text:
                        html += text.string
                    //Add more inline types here.
                    default:
                        html += inline.debugDescription()
                    }

                }
                html += "</p>"
            // Add more cases for other block types
            default:
                html += block.debugDescription()
            }
        }

        html += "</body></html>"
        return html
    }
    
    // For future expansion - different specifications
    private func applySpecificationRules(_ document: Document) -> Document {
        // Here we would apply specific rules based on the selected specification
        switch specification {
        case .commonMark:
            // Apply CommonMark specific rules
            break
        case .githubFlavored:
            // Apply GitHub Flavored Markdown rules
            break
        case .pandoc:
            // Apply Pandoc specific rules
            break
        }

        return document
    }
}
