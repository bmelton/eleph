import SwiftUI
import ElephCore

public struct NavigationPane: View {
    @Binding public var searchText: String
    @Binding public var selectedDocument: Document?
    
    // Track the collapsed state of sections
    @State private var quickAccessCollapsed = false
    @State private var tagsCollapsed = false
    
    public init(searchText: Binding<String>, selectedDocument: Binding<Document?>) {
        self._searchText = searchText
        self._selectedDocument = selectedDocument
    }
    
    // Sample folders and tags (will be replaced with actual data model)
    @State private var folders = ["All Notes", "Personal", "Work", "Ideas"]
    @State private var tags = ["important", "draft", "completed", "reference"]
    
    public var body: some View {
        List {
            /*
            DisclosureGroup(
                isExpanded: .constant(!quickAccessCollapsed), //Use constant and toggle state directly.
                content: {
                    ForEach(folders, id: \.self) { folder in
                        Label(folder, systemImage: "folder")
                            .tag(folder)
                            .padding(.vertical, 2)
                    }
                    
                    Label("Trash", systemImage: "trash")
                        .tag("Trash")
                        .padding(.vertical, 2)
                },
                label: {
                    Text("Quick Access")
                        .font(.headline)
                }
            )
             */
            DisclosureGroup(isExpanded: .constant(!quickAccessCollapsed)) {
                LazyVStack {
                    ForEach(folders, id: \.self) { folder in
                        Label(folder, systemImage: "folder")
                            .tag(folder)
                            .padding(.vertical, 2)
                    }
                    Label("Trash", systemImage: "trash")
                        .tag("Trash")
                        .padding(.vertical, 2)
                }
            } label: {
                Text("Quick Access")
                    .font(.headline)
            }
            .padding(.vertical, 2)
            .onTapGesture{
                quickAccessCollapsed.toggle()
            }
            
            DisclosureGroup(
                isExpanded: .constant(!tagsCollapsed), //Use constant and toggle state directly.
                content: {
                    ForEach(tags, id: \.self) { tag in
                        Label(tag, systemImage: "tag")
                            .tag(tag)
                            .padding(.vertical, 2)
                    }
                },
                label: {
                    Text("Tags")
                        .font(.headline)
                }
            )
            .padding(.vertical, 2)
            .onTapGesture{
                tagsCollapsed.toggle()
            }
        }
        .listStyle(.sidebar)
        .animation(.easeInOut(duration: 0.2), value: quickAccessCollapsed)
        .animation(.easeInOut(duration: 0.2), value: tagsCollapsed)
        .searchable(text: $searchText, prompt: "Search notes...")
    }
}
