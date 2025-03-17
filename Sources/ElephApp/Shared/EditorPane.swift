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
                
                Spacer()
                
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
            }
            .padding()
            .background(themeManager.currentTheme.toolbarBackground)
            
            // Editor/Preview content
            ZStack {
                // Editor
                if editMode {
                    #if os(macOS)
                    TextEditor(text: $document.content)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .padding()
                        .background(themeManager.currentTheme.editorBackground)
                        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                    #else
                    TextEditor(text: $document.content)
                        .font(.system(size: 14, weight: .regular, design: .monospaced))
                        .padding()
                        .background(themeManager.currentTheme.editorBackground)
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
    }
    
    // Helper method to insert Markdown into the document
    private func insertMarkdown(_ markdown: String) {
        if editMode {
            document.content.append("\n\(markdown)")
        }
    }
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