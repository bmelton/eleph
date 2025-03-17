import SwiftUI
import ElephCore

public struct PreviewPane: View {
    public let searchText: String
    @Binding public var selectedDocument: Document?
    
    public init(searchText: String, selectedDocument: Binding<Document?>) {
        self.searchText = searchText
        self._selectedDocument = selectedDocument
    }
    
    // Sample documents (will be replaced with actual data model)
    @State private var documents = [
        Document(id: "1", title: "Getting Started with Markdown", content: "# Getting Started with Markdown\n\nMarkdown is a lightweight markup language that you can use to add formatting elements to plaintext text documents.\n\n## Why Use Markdown?\n\nMarkdown is portable, platform independent, and future proof.", lastModified: Date()),
        Document(id: "2", title: "Project Ideas", content: "# Project Ideas\n\n## Mobile Apps\n- Note taking app with markdown support\n- Habit tracker with insights\n\n## Web Applications\n- Portfolio website\n- Recipe manager", lastModified: Date().addingTimeInterval(-86400)),
        Document(id: "3", title: "Meeting Notes", content: "# Team Meeting - March 15\n\n## Agenda\n1. Project status updates\n2. Upcoming deadlines\n3. Open discussion\n\n## Action Items\n- [ ] Send follow-up email\n- [ ] Schedule next meeting", lastModified: Date().addingTimeInterval(-172800))
    ]
    
    var filteredDocuments: [Document] {
        if searchText.isEmpty {
            return documents
        } else {
            return documents.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) || 
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    public var body: some View {
        List(filteredDocuments) { document in
            DocumentPreviewRow(document: document)
                .onTapGesture {
                    selectedDocument = document
                }
        }
        .listStyle(.plain)
    }
}

public struct DocumentPreviewRow: View {
    public let document: Document
    
    public init(document: Document) {
        self.document = document
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(document.title)
                .font(.headline)
            
            Text(document.previewText)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            Text(document.formattedDate)
                .font(.caption)
                .foregroundColor(Color.gray.opacity(0.6))
        }
        .padding(.vertical, 8)
    }
}