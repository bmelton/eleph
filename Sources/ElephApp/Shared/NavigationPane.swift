import SwiftUI
import ElephCore
// import ElephCore.Storage -- You keep adding ElephCore.Storage but it isn't needed, nor does it work.

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
    
    // Edit mode state
    @State private var isEditMode = false
    @State private var showingDeleteConfirmation = false
    @State private var itemToDelete: (type: ItemType, name: String)? = nil
    
    // Define item types for deletion
    enum ItemType {
        case folder
        case tag
    }
    
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
    
    // MARK: - Edit Mode
    
    private func toggleEditMode() {
        isEditMode.toggle()
    }
    
    private func confirmDeletion(type: ItemType, name: String) {
        itemToDelete = (type: type, name: name)
        showingDeleteConfirmation = true
    }
    
    private func deleteItem() {
        guard let item = itemToDelete else { return }
        
        switch item.type {
        case .folder:
            removeFolder(item.name)
        case .tag:
            removeTag(item.name)
        }
        
        itemToDelete = nil
    }
    
    // MARK: - View Body
    
    public var body: some View {
        List {
            /*
            Section {
                ForEach(folders, id: \.self) { folder in
                    if isEditMode {
                        HStack {
                            Text(folder)
                            Spacer()
                            Button {
                                confirmDeletion(type: .folder, name: folder)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle()) // Prevents the whole row from being a button
                        }
                        .tag(folder)
                        .padding(.vertical, 2)
                    } else {
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
                    
                Button {
                    toggleEditMode()
                } label: {
                    Label(isEditMode ? "Done" : "Edit", systemImage: isEditMode ? "checkmark" : "pencil")
                }
                .padding(.vertical, 2)
            } header: {
                Text("Quick Access").font(.headline)
            }
            .padding(.vertical, 2)
            */

            Section {
                ForEach(tags, id: \.self) { tag in
                    if isEditMode {
                        HStack {
                            Text(tag)
                            Spacer()
                            Button {
                                confirmDeletion(type: .tag, name: tag)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(BorderlessButtonStyle()) // Prevents the whole row from being a button
                        }
                        .tag(tag)
                        .padding(.vertical, 2)
                    } else {
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
                }
                
                Button {
                    addNewTag()
                } label: {
                    Label("Add Tag", systemImage: "plus")
                }
                .padding(.top, 4)
                Divider()
                HStack {
                    Label("Trash", systemImage: "trash")
                        .tag("Trash")
                        .padding(.vertical, 2)
                    Spacer()
                    Button {
                        toggleEditMode()
                    } label: {
                        Label(isEditMode ? "Done" : "Edit", systemImage: isEditMode ? "checkmark" : "pencil")
                    }
                }
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
        .alert("Confirm Deletion", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteItem()
            }
        } message: {
            if let item = itemToDelete {
                Text("Are you sure you want to delete '\(item.name)'?")
            } else {
                Text("Are you sure you want to delete this item?")
            }
        }
    }
}
