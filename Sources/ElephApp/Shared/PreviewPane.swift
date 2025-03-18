import SwiftUI
import ElephCore
import Combine

struct ContentView: View {
    @State private var selectedDocument: Document? = nil
    @State private var searchText: String = ""
    
    var body: some View {
        VStack {
            TextField("Search", text: $searchText)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            PreviewPane(searchText: searchText, selectedDocument: $selectedDocument)
        }
        .padding()
        .onAppear {
            // Create test documents with US Constitution text
            Document.createTestDocuments()
        }
    }
}

// Modified PreviewPane for testing
struct PreviewPane: View {
    public let searchText: String
    @Binding public var selectedDocument: Document?
    @State private var documents: [Document] = []
    
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
                
                Button(action: {}) {
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
            }
            .listStyle(.plain)
        }
        .onAppear {
            self.documents = Document.loadTestDocuments()
        }
    }
}

struct DocumentPreviewRow: View {
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
    }
}

// Simplified Document class for testing
public class Document: ObservableObject, Identifiable {
    public let id: UUID
    @Published public var title: String
    @Published public var content: String
    @Published public var lastModified: Date
    
    public init(id: UUID = UUID(), title: String, content: String, lastModified: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.lastModified = lastModified
    }
    
    public var extractedTitle: String {
        return title
    }
    
    public var previewText: String {
        return content.prefix(200) + (content.count > 200 ? "..." : "")
    }
    
    public var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: lastModified)
    }

    // Test documents with US Constitution text
    public static func createTestDocuments() {
        // Implementation for test purposes
    }
    
    public static func loadTestDocuments() -> [Document] {
        let preamble = Document(
            title: "US Constitution - Preamble",
            content: "We the People of the United States, in Order to form a more perfect Union, establish Justice, insure domestic Tranquility, provide for the common defence, promote the general Welfare, and secure the Blessings of Liberty to ourselves and our Posterity, do ordain and establish this Constitution for the United States of America."
        )
        
        let articleOne = Document(
            title: "US Constitution - Article I",
            content: "Article I\n\nSection 1\nAll legislative Powers herein granted shall be vested in a Congress of the United States, which shall consist of a Senate and House of Representatives.\n\nSection 2\nThe House of Representatives shall be composed of Members chosen every second Year by the People of the several States, and the Electors in each State shall have the Qualifications requisite for Electors of the most numerous Branch of the State Legislature."
        )
        
        let articleTwo = Document(
            title: "US Constitution - Article II",
            content: """
            Article II
            
            Section 1
            
            The executive Power shall be vested in a President of the United States of America. He shall hold his Office during the Term of four Years, and, together with the Vice President, chosen for the same Term, be elected, as follows...\n\nEach State shall appoint, in such Manner as the Legislature thereof may direct, a Number of Electors, equal to the whole Number of Senators and Representatives to which the State may be entitled in the Congress: but no Senator or Representative, or Person holding an Office of Trust or Profit under the United States, shall be appointed an Elector.
            """
        )
        
        let billOfRights = Document(
            title: "US Constitution - Bill of Rights",
            content: "Amendment I\nCongress shall make no law respecting an establishment of religion, or prohibiting the free exercise thereof; or abridging the freedom of speech, or of the press; or the right of the people peaceably to assemble, and to petition the Government for a redress of grievances.\n\nAmendment II\nA well regulated Militia, being necessary to the security of a free State, the right of the people to keep and bear Arms, shall not be infringed.\n\nAmendment III\nNo Soldier shall, in time of peace be quartered in any house, without the consent of the Owner, nor in time of war, but in a manner to be prescribed by law."
        )
        
        return [preamble, articleOne, articleTwo, billOfRights]
    }
}

/*
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
*/
