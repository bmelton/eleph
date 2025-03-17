import Foundation

public struct TagsAndFolders: Codable {
    public var folders: [String]
    public var tags: [String]
    
    public init(folders: [String] = [], tags: [String] = []) {
        self.folders = folders
        self.tags = tags
    }
}

public class TagsAndFoldersStorage {
    private static let defaultFolders = ["All Notes", "Personal", "Work", "Ideas"]
    private static let defaultTags = ["important", "draft", "completed", "reference"]
    
    private let fileManager = FileManager.default
    private let plistFileName = "ElephTagsAndFolders.plist"
    
    // Computed property to get the app's documents directory URL
    private var documentsDirectoryURL: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    public init() {}
    
    // URL for the app's metadata directory (to store our .plist file)
    private var metadataDirectoryURL: URL {
        let metadataDir = documentsDirectoryURL.appendingPathComponent(".eleph_metadata", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: metadataDir.path) {
            try? fileManager.createDirectory(at: metadataDir, withIntermediateDirectories: true)
        }
        
        return metadataDir
    }
    
    // URL for the .plist file
    private var plistURL: URL {
        metadataDirectoryURL.appendingPathComponent(plistFileName)
    }
    
    // Initialize the storage on app start
    public func initialize() {
        // Check if .plist file exists, create it with defaults if it doesn't
        if !fileManager.fileExists(atPath: plistURL.path) {
            let defaultData = TagsAndFolders(folders: TagsAndFoldersStorage.defaultFolders,
                                           tags: TagsAndFoldersStorage.defaultTags)
            save(data: defaultData)
        }
        
        // Setup iCloud sync for the metadata directory if available
        setupiCloudSync()
    }
    
    // Setup iCloud sync capability for the metadata directory
    private func setupiCloudSync() {
        #if os(iOS) || os(macOS)
        if fileManager.ubiquityIdentityToken != nil {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = false
            do {
                // Store the URL in a variable first, then call the mutating method on it
                var fileURL = metadataDirectoryURL.appendingPathComponent(plistFileName)
                try fileURL.setResourceValues(resourceValues)
            } catch {
                print("Error setting iCloud resource values: \(error)")
            }
        }
        #endif
    }
    
    // Save tags and folders data
    public func save(data: TagsAndFolders) {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        
        do {
            let data = try encoder.encode(data)
            try data.write(to: plistURL)
        } catch {
            print("Error saving tags and folders data: \(error)")
        }
    }
    
    // Load tags and folders data
    public func load() -> TagsAndFolders {
        guard fileManager.fileExists(atPath: plistURL.path) else {
            // Return defaults if file doesn't exist
            return TagsAndFolders(folders: TagsAndFoldersStorage.defaultFolders,
                                tags: TagsAndFoldersStorage.defaultTags)
        }
        
        do {
            let data = try Data(contentsOf: plistURL)
            let decoder = PropertyListDecoder()
            return try decoder.decode(TagsAndFolders.self, from: data)
        } catch {
            print("Error loading tags and folders data: \(error)")
            // Return defaults on error
            return TagsAndFolders(folders: TagsAndFoldersStorage.defaultFolders,
                                tags: TagsAndFoldersStorage.defaultTags)
        }
    }
    
    // Add a new folder
    public func addFolder(_ folder: String) {
        var data = load()
        if !data.folders.contains(folder) {
            data.folders.append(folder)
            save(data: data)
        }
    }
    
    // Remove a folder
    public func removeFolder(_ folder: String) {
        var data = load()
        data.folders.removeAll { $0 == folder }
        save(data: data)
    }
    
    // Add a new tag
    public func addTag(_ tag: String) {
        var data = load()
        if !data.tags.contains(tag) {
            data.tags.append(tag)
            save(data: data)
        }
    }
    
    // Remove a tag
    public func removeTag(_ tag: String) {
        var data = load()
        data.tags.removeAll { $0 == tag }
        save(data: data)
    }
}
