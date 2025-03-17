import Foundation
import Markdown

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
    public func toAttributedString(markdown: String) -> AttributedString {
        do {
            // Using the built-in AttributedString from SwiftUI
            return try AttributedString(markdown: markdown)
        } catch {
            print("Error converting markdown to AttributedString: \(error)")
            return AttributedString(markdown)
        }
    }
    
    // Convert markdown to HTML
    public func toHTML(markdown: String) -> String {
        let _ = parse(markdown)
        
        // Basic HTML conversion
        // In a real implementation, this would traverse the AST and build proper HTML
        let html = "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><title></title></head><body>\(markdown)</body></html>"
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
