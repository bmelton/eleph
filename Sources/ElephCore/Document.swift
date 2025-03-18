import Foundation
import SwiftUI

public class Document: ObservableObject, Identifiable {
    public let id: String
    @Published public var title: String
    @Published public var content: String
    @Published public var lastModified: Date
    @Published public var tags: [String]
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        content: String,
        lastModified: Date = Date(),
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.lastModified = lastModified
        self.tags = tags
    }
    
    public var previewText: String {
        // Extract the first non-empty paragraph after removing markdown formatting
        let cleanedText = content
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "_", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Split into paragraphs and find the first non-empty one
        let paragraphs = cleanedText.components(separatedBy: "\n\n")
        let nonEmptyParagraphs = paragraphs.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        if let firstParagraph = nonEmptyParagraphs.first {
            // Further clean up the paragraph
            return firstParagraph
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\n", with: " ")
        }
        
        return cleanedText
    }
    
    // Extract a title from the content if possible
    public var extractedTitle: String {
        // Try to find the first heading (# Title)
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.hasPrefix("#") {
                // Remove the # and any leading/trailing whitespace
                let titleLine = trimmed
                    .replacingOccurrences(of: "^#+\\s*", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !titleLine.isEmpty {
                    return titleLine
                }
            }
        }
        
        return title
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: lastModified)
    }
    
    // Simple save method without any timers or async behavior
    public func save() {
        do {
            let directory = Document.getDocumentsDirectory()
            
            // Ensure directory exists
            if !FileManager.default.fileExists(atPath: directory.path) {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            }
            
            // Update last modified date
            self.lastModified = Date()
            
            // If title is still "Untitled Document" but we can extract a better title from content, use it
            if title == "Untitled Document" {
                let extracted = extractedTitle
                if extracted != title {
                    title = extracted
                }
            }
            
            // Create the file content with YAML frontmatter
            var fileContent = "---\n"
            fileContent += "id: \(id)\n"
            fileContent += "title: \(title)\n"
            fileContent += "lastModified: \(ISO8601DateFormatter().string(from: lastModified))\n"
            
            if !tags.isEmpty {
                fileContent += "tags: [\(tags.map { "\"\($0)\"" }.joined(separator: ", "))]\n"
            } else {
                fileContent += "tags: []\n"
            }
            
            fileContent += "---\n\n"
            fileContent += content
            
            // Write to file
            let fileURL = directory.appendingPathComponent("\(id).md")
            try fileContent.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error saving document: \(error)")
        }
    }
}

// Extension for document operations
extension Document {
    public static var samples: [Document] {
        [
            Document(
                id: "1",
                title: "Getting Started with Markdown",
                content: """
                # Getting Started with Markdown
                
                Markdown is a lightweight markup language that you can use to add formatting elements to plaintext text documents.
                
                ## Why Use Markdown?
                
                Markdown is portable, platform independent, and future proof.
                
                - Easy to learn
                - Fast to type
                - Clean to read
                """,
                lastModified: Date()
            ),
            Document(
                id: "2",
                title: "Project Ideas",
                content: """
                # Project Ideas
                
                ## Mobile Apps
                - Note taking app with markdown support
                - Habit tracker with insights
                
                ## Web Applications
                - Portfolio website
                - Recipe manager
                """,
                lastModified: Date().addingTimeInterval(-86400)
            )
        ]
    }
    
    public static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0].appendingPathComponent("ElephDocuments")
        return documentsDirectory
    }
    
    public static func loadDocuments() -> [Document] {
        let directory = getDocumentsDirectory()
        var documents: [Document] = []
        
        do {
            // Create directory if it doesn't exist
            if !FileManager.default.fileExists(atPath: directory.path) {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                
                // Create and save sample documents
                for sample in samples {
                    sample.save()
                }
                return samples
            }
            
            // Load documents from directory
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs where fileURL.pathExtension == "md" {
                if let document = loadDocumentFromFile(fileURL) {
                    documents.append(document)
                }
            }
        } catch {
            print("Error loading documents: \(error)")
        }
        
        return documents.isEmpty ? samples : documents
    }
    
    private static func loadDocumentFromFile(_ fileURL: URL) -> Document? {
        do {
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            
            // Parse YAML frontmatter
            if fileContent.hasPrefix("---") {
                // Split by frontmatter delimiter
                let components = fileContent.components(separatedBy: "---")
                
                if components.count >= 3 {
                    // First component is empty (before the first ---)
                    // Second component is the frontmatter
                    let frontMatter = components[1]
                    
                    // Everything after the second --- is content
                    // Join with --- in case the content has --- horizontal rules
                    let markdownContent = components[2...].joined(separator: "---")
                                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Parse the frontmatter
                    var id = fileURL.deletingPathExtension().lastPathComponent
                    var title = "Untitled"
                    var lastModified = Date()
                    var tags: [String] = []
                    
                    // Process frontmatter lines
                    for line in frontMatter.components(separatedBy: .newlines) {
                        let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
                        if let colonIndex = trimmedLine.firstIndex(of: ":") {
                            let key = String(trimmedLine[..<colonIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
                            let value = String(trimmedLine[trimmedLine.index(after: colonIndex)...]).trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            switch key {
                            case "id":
                                id = value
                            case "title":
                                title = value
                            case "lastModified":
                                if let date = ISO8601DateFormatter().date(from: value) {
                                    lastModified = date
                                }
                            case "tags":
                                // Simple parsing of array format [item1, item2]
                                let tagsString = value.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
                                tags = tagsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "\"'")) }
                            default:
                                break
                            }
                        }
                    }
                    
                    return Document(id: id, title: title, content: markdownContent, lastModified: lastModified, tags: tags)
                }
            }
            
            // No frontmatter, treat entire file as content
            let title = fileURL.deletingPathExtension().lastPathComponent
            return Document(id: fileURL.deletingPathExtension().lastPathComponent, title: title, content: fileContent)
            
        } catch {
            print("Error reading document file: \(error)")
            return nil
        }
    }
    
    public static func createNewDocument() -> Document {
        let newDocument = Document(
            title: "Untitled Document",
            content: "# Untitled Document\n\nStart writing here...",
            lastModified: Date()
        )
        
        newDocument.save()
        return newDocument
    }
}