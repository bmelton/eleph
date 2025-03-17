import SwiftUI
import ElephCore


public struct NavigationPane: View {
    @Binding public var searchText: String
    @Binding public var selectedDocument: Document?
    
    // Track the collapsed state of sections
    @State private var quickAccessCollapsed = false
    @State private var tagsCollapsed = false
    
    // Storage for tags and folders
    private let storage = TagsAndFoldersStorage()
    
    // State properties for folders and tags loaded from storage
    @State private var folders: [String] = []
    @State private var tags: [String] = []
    
    public init(searchText: Binding<String>, selectedDocument: Binding<Document?>) {
        self._searchText = searchText
        self._selectedDocument = selectedDocument
    }
    
    // Load data from storage
    private func loadData() {
        let data = storage.load()
        folders = data.folders
        tags = data.tags
    }
    
    // STATE MANAGEMENT
    @State private var showingAddFolderAlert = false
    @State private var showingAddTagAlert = false
    @State private var newFolderName = ""
    @State private var newTagName = ""
    
    // FOLDER METHODS
    private func addNewFolder() {
        showingAddFolderAlert = true
    }
    
    private func removeFolder(_ folder: String) {
        storage.removeFolder(folder)
        loadData() // Reload data
    }
    
    private func confirmAddFolder() {
        guard !newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        storage.addFolder(newFolderName.trimmingCharacters(in: .whitespacesAndNewlines))
        newFolderName = ""
        loadData() // Reload data
    }
    
    // TAG METHODS
    private func addNewTag() {
        showingAddTagAlert = true
    }
    
    private func removeTag(_ tag: String) {
        storage.removeTag(tag)
        loadData() // Reload data
    }
    
    private func confirmAddTag() {
        guard !newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        storage.addTag(newTagName.trimmingCharacters(in: .whitespacesAndNewlines))
        newTagName = ""
        loadData() // Reload data
    }
    
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
                            .contextMenu {
                                Button(role: .destructive) {
                                    removeFolder(folder)
                                } label: {
                                    Label("Remove Folder", systemImage: "trash")
                                }
                            }
                    }
                    
                    Button {
                        addNewFolder()
                    } label: {
                        Label("Add Folder", systemImage: "plus")
                    }
                    .padding(.vertical, 2)
                    
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
                            .contextMenu {
                                Button(role: .destructive) {
                                    removeTag(tag)
                                } label: {
                                    Label("Remove Tag", systemImage: "trash")
                                }
                            }
                    }
                    
                    Button {
                        addNewTag()
                    } label: {
                        Label("Add Tag", systemImage: "plus")
                    }
                    .padding(.top, 4)
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
        .onAppear {
            loadData()
        }
        .alert("Add New Folder", isPresented: $showingAddFolderAlert) {
            TextField("Folder Name", text: $newFolderName)
            Button("Cancel", role: .cancel) { 
                newFolderName = "" 
            }
            Button("Add") { 
                confirmAddFolder() 
            }
        } message: {
            Text("Enter a name for the new folder")
        }
        .alert("Add New Tag", isPresented: $showingAddTagAlert) {
            TextField("Tag Name", text: $newTagName)
            Button("Cancel", role: .cancel) { 
                newTagName = "" 
            }
            Button("Add") { 
                confirmAddTag() 
            }
        } message: {
            Text("Enter a name for the new tag")
        }
    }
}
