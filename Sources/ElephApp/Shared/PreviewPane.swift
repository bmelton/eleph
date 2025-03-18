import SwiftUI
import ElephCore

public struct PreviewPane: View {
    public let searchText: String
    @Binding public var selectedDocument: Document?
    @State private var documents: [Document] = []
    @State private var refreshTimer: Timer? = nil
    
    public init(searchText: String, selectedDocument: Binding<Document?>) {
        self.searchText = searchText
        self._selectedDocument = selectedDocument
    }
    
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
        VStack {
            HStack {
                Text("Documents")
                    .font(.headline)
                    .padding(.leading)
                
                Spacer()
                
                Button(action: createNewDocument) {
                    Label("New", systemImage: "plus")
                }
                .buttonStyle(.bordered)
                .padding(.trailing)
            }
            .padding(.top, 8)
            
            List(filteredDocuments) { document in
                
                DocumentPreviewRow(document: document)
                    .onTapGesture {
                        selectedDocument = document
                    }
                    .id("\(document.id)-\(document.lastModified.timeIntervalSince1970)")
            }
            .listStyle(.plain)
            .id(UUID()) // Force refresh when documents change
        }
        .onAppear {
            loadDocuments()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RefreshDocumentsList"))) { _ in
            loadDocuments()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DocumentUpdated"))) { notification in
            // When a document is updated, refresh the document list
            loadDocuments()
        }
    }
    
    private func loadDocuments() {
        // Store currently selected document ID to maintain selection
        let selectedID = selectedDocument?.id
        
        // Load fresh documents
        let freshDocuments = Document.loadDocuments()
        
        // Sort by last modified date (newest first)
        self.documents = freshDocuments.sorted { $0.lastModified > $1.lastModified }
        
        // If we had a selected document, update the reference to the fresh one
        if let selectedID = selectedID, 
           let freshDocument = documents.first(where: { $0.id == selectedID }) {
            // Only update if not the same instance
            if selectedDocument?.id == freshDocument.id && selectedDocument !== freshDocument {
                selectedDocument = freshDocument
            }
        }
    }
    
    private func createNewDocument() {
        let newDocument = Document.createNewDocument()
        self.documents.insert(newDocument, at: 0)
        self.selectedDocument = newDocument
    }
}

public struct DocumentPreviewRow: View {
    // Use a regular reference rather than @ObservedObject to avoid potential retain cycles
    public let document: Document
    
    public init(document: Document) {
        self.document = document
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(document.extractedTitle)
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
        // Use ID to force refresh when document changes
        .id("\(document.id)-\(document.lastModified.timeIntervalSince1970)")
    }
}
