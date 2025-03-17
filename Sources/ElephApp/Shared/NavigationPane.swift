import SwiftUI
import ElephCore

public struct NavigationPane: View {
    @Binding public var searchText: String
    @Binding public var selectedDocument: Document?
    
    public init(searchText: Binding<String>, selectedDocument: Binding<Document?>) {
        self._searchText = searchText
        self._selectedDocument = selectedDocument
    }
    
    // Sample folders and tags (will be replaced with actual data model)
    @State private var folders = ["All Notes", "Personal", "Work", "Ideas"]
    @State private var tags = ["important", "draft", "completed", "reference"]
    
    public var body: some View {
        List {
            Section("Quick Access") {
                ForEach(folders, id: \.self) { folder in
                    Label(folder, systemImage: "folder")
                        .tag(folder)
                }
                
                Label("Trash", systemImage: "trash")
                    .tag("Trash")
            }
            
            Section("Tags") {
                ForEach(tags, id: \.self) { tag in
                    Label(tag, systemImage: "tag")
                        .tag(tag)
                }
            }
        }
        .listStyle(.sidebar)
        .searchable(text: $searchText, prompt: "Search notes...")
    }
}