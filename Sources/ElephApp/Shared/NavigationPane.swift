import SwiftUI
import ElephCore

public struct NavigationPane: View {
    @Binding public var searchText: String
    @Binding public var selectedDocument: Document?
    
    // MARK: - Properties
    
    // Storage for tags and folders
    private let storage = TagsAndFoldersStorage()
    
    // State properties for folders and tags loaded from storage
    @State private var folders: [String] = []
    @State private var tags: [String] = []
    @State private var showingAddFolderAlert = false
    @State private var showingAddTagAlert = false
    @State private var newFolderName = ""
    @State private var newTagName = ""
    
    // MARK: - Initialization
    
    public init(searchText: Binding<String>, selectedDocument: Binding<Document?>) {
        self._searchText = searchText
        self._selectedDocument = selectedDocument
    }
    
    // MARK: - Data Management
    
    private func loadData() {
        let data = storage.load()
        folders = data.folders
        tags = data.tags
    }
    
    // MARK: - Folder Management
    
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
    
    // MARK: - Tag Management
    
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
    
    // MARK: - View Body
    
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
            Section {
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
            } header: {
                Text("Quick Access").font(.headline)
            }
            .padding(.vertical, 2)
            
            Section {
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
            } header: {
                Text("Tags").font(.headline)
            }
            .padding(.vertical, 2)
        }
        .listStyle(.sidebar)
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
