/*
import SwiftUI
import OSLog
import ElephThemes
import ElephCore
import ElephMarkdown

// Add this extension to your project
extension String {
    // Helper to visualize invisible characters like line breaks
    var debugRepresentation: String {
        self.replacingOccurrences(of: "\n", with: "⏎\n")
            .replacingOccurrences(of: "\t", with: "→\t")
            .replacingOccurrences(of: " ", with: "·")
    }
}

// Modified version of your editor pane with debugging
public struct EditorPane: View {
    @ObservedObject public var document: Document
    @State private var editMode = true
    @EnvironmentObject private var themeManager: ThemeManager
    
    // Add a logger
    private let logger = Logger(subsystem: "com.yourdomain.app", category: "EditorPane")
    
    public init(document: Document) {
        self.document = document
        
        // Log document content on initialization
        print("INIT DOCUMENT: \(document.content.debugRepresentation)")
        print("CONTENT LENGTH: \(document.content.count)")
        print("LINE BREAKS COUNT: \(document.content.filter { $0 == "\n" }.count)")
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Debug controls
            HStack {
                Button("Log Content") {
                    print("DOCUMENT CONTENT: \(document.content.debugRepresentation)")
                    print("CONTENT LENGTH: \(document.content.count)")
                    print("LINE BREAKS COUNT: \(document.content.filter { $0 == "\n" }.count)")
                }
                
                Button("Test Line Breaks") {
                    // Test by injecting sample text with line breaks
                    document.content = "Line 1\nLine 2\nLine 3\n\nLine 5 after empty line"
                    print("TEST CONTENT ADDED")
                }
                
                Toggle("Edit Mode", isOn: $editMode)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            
            // Rest of your existing toolbar
            HStack {
                Button(action: { editMode.toggle() }) {
                    Label(editMode ? "Preview" : "Edit", systemImage: editMode ? "eye" : "pencil")
                }
                // Your other toolbar items...
            }
            .padding()
            .background(themeManager.currentTheme.toolbarBackground)
            
            // Editor/Preview content
            ZStack {
                // Editor
                if editMode {
                    #if os(macOS)
                    TextEditor(text: $document.content)
                        .font(.body)
                        .padding()
                        .background(themeManager.currentTheme.editorBackground)
                        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                        .onChange(of: document.content) { newValue in
                            // Debug line break changes
                            print("CONTENT CHANGED: Line breaks count: \(newValue.filter { $0 == "\n" }.count)")
                        }
                    #else
                    TextEditor(text: $document.content)
                        .font(.body)
                        .padding()
                        .background(themeManager.currentTheme.editorBackground)
                        .onChange(of: document.content) { newValue in
                            // Debug line break changes
                            print("CONTENT CHANGED: Line breaks count: \(newValue.filter { $0 == "\n" }.count)")
                        }
                    #endif
                } else {
                    // Preview with debugging
                    VStack {
                        // Add a debug representation above the actual preview
                        ScrollView {
                            Text("Debug Preview (showing line breaks):")
                                .font(.headline)
                                .padding(.top)
                            
                            Text(document.content.debugRepresentation)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.black.opacity(0.1))
                        }
                        .frame(height: 200)
                        
                        Divider()
                        
                        // Your regular preview
                        #if os(macOS)
                        MarkdownView(
                            markdown: document.content,
                            theme: themeManager.currentTheme
                        )
                        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
                        .background(themeManager.currentTheme.editorBackground)
                        #else
                        MarkdownView(
                            markdown: document.content,
                            theme: themeManager.currentTheme
                        )
                        .background(themeManager.currentTheme.editorBackground)
                        #endif
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: editMode)
        }
        .onAppear {
            // Log on appear
            print("EDITOR PANE APPEARED: Document content has \(document.content.filter { $0 == "\n" }.count) line breaks")
        }
    }
}
*/
/*
import SwiftUI
import ElephCore
import ElephMarkdown
import ElephThemes

public struct EditorPane: View {
    @ObservedObject public var document: Document
    
    public init(document: Document) {
        self.document = document
    }
    @State private var editMode = true
    @EnvironmentObject private var themeManager: ThemeManager
    
    public var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Button(action: { editMode.toggle() }) {
                    Label(editMode ? "Preview" : "Edit", systemImage: editMode ? "eye" : "pencil")
                }
                /*

                Spacer()
                
                // Save button
                Button(action: { document.save() }) {
                    Label("Save", systemImage: "arrow.down.doc")
                }
                .help("Save Document")
                
                // Add some additional tools
                HStack(spacing: 12) {
                    // Heading button
                    Button(action: { insertMarkdown("# ") }) {
                        Image(systemName: "textformat.size")
                    }
                    .help("Insert Heading")
                    
                    // Bold button
                    Button(action: { insertMarkdown("**bold text**") }) {
                        Image(systemName: "bold")
                    }
                    .help("Bold")
                    
                    // Italic button
                    Button(action: { insertMarkdown("*italic text*") }) {
                        Image(systemName: "italic")
                    }
                    .help("Italic")
                    
                    // List button
                    Button(action: { insertMarkdown("- ") }) {
                        Image(systemName: "list.bullet")
                    }
                    .help("Bullet List")
                    
                    // Share button
                    Button(action: {}) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .help("Share")
                }
                 */
            }
            .padding()
            .background(themeManager.currentTheme.toolbarBackground)
            // Editor/Preview content
            ZStack {
                // Editor
                if editMode {
                    #if os(macOS)
                    TextEditor(text: $document.content)
                        // .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .font(.body)
                        .padding()
                        .background(themeManager.currentTheme.editorBackground)
                        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                        /*
                        .onChange(of: document.content) { _ in
                            // Post notification that document has been updated
                            NotificationCenter.default.post(name: NSNotification.Name("DocumentUpdated"), object: document)
                        }
                       */
                    #else
                    TextEditor(text: $document.content)
                        // .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .font(.body)
                        .padding()
                        .background(themeManager.currentTheme.editorBackground)
                        .onChange(of: document.content) { _ in
                            // Post notification that document has been updated
                            // NotificationCenter.default.post(name: NSNotification.Name("DocumentUpdated"), object: document)
                        }
                    #endif
                } else {
                    // Preview
                    #if os(macOS)
                    MarkdownView(
                        markdown: document.content,
                        theme: themeManager.currentTheme
                    )
                    .frame(minWidth: 400, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                    .background(themeManager.currentTheme.editorBackground)
                    #else
                    MarkdownView(
                        markdown: document.content,
                        theme: themeManager.currentTheme
                    )
                    .background(themeManager.currentTheme.editorBackground)
                    #endif
                }
            }
            .animation(.easeInOut(duration: 0.3), value: editMode)
        }
        .onDisappear {
            // Save document when view disappears
            // document.save()
        }
    }

    // Helper method to insert Markdown into the document
    /*
    private func insertMarkdown(_ markdown: String) {
        if editMode {
            document.content.append("\n\(markdown)")
            // Trigger save on insert
            document.save()
            // Notify document was updated
            NotificationCenter.default.post(name: NSNotification.Name("DocumentUpdated"), object: document)
        }
    }
     */
}
 
public struct MarkdownView: View {
    public let markdown: String
    public let theme: Theme
    
    public init(markdown: String, theme: Theme) {
        self.markdown = markdown
        self.theme = theme
    }
    
    public var body: some View {
        if #available(macOS 13.0, iOS 16.0, *) {
            // Use the newer SwiftUI native Markdown view on newer systems
            NativeMarkdownView(markdown: markdown, theme: theme)
        } else {
            // Use our custom renderer for older systems
            MarkdownRendererView(
                markdown: markdown,
                specification: .commonMark,
                theme: theme
            )
        }
    }
}

@available(macOS 13.0, iOS 16.0, *)
private struct NativeMarkdownView: View {
    let markdown: String
    let theme: Theme
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                let markdownString = try? AttributedString(markdown: markdown)
                
                if let markdownString = markdownString {
                    Text(markdownString)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    // Fallback if parsing fails
                    Text(markdown)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
        .background(theme.editorBackground)
    }
}
*/
