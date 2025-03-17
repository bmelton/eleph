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
        // Remove Markdown formatting for the preview
        content
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "*", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: lastModified)
    }
}

// Extension for sample data
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
}