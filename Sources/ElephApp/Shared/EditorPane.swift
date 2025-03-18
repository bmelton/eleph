import SwiftUI
import ElephCore
import ElephMarkdown
import ElephThemes
import AppKit

public struct MarkdownView: View {
    public let markdown: String
    public let theme: Theme

    public init(markdown: String, theme: Theme) {
        self.markdown = markdown
        self.theme = theme
    }
    
    @State private var editMode = true
    @EnvironmentObject private var themeManager: ThemeManager

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

public struct EditorPane: View {
    @ObservedObject public var document: Document

    public init(document: Document) {
        self.document = document
    }
    @State private var editMode = true
    @EnvironmentObject private var themeManager: ThemeManager // Correctly injected

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
            .background(themeManager.currentTheme.toolbarBackground) // Correct usage

            // Editor/Preview content
            ZStack {
                // Editor
                if editMode {
                    RichTextEditor(text: $document.content, theme: themeManager.currentTheme) // Correct usage
                        .padding()
                        .background(themeManager.currentTheme.editorBackground) // Correct usage
                        .frame(minWidth: 400, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                } else {
                    // Preview
                    MarkdownView(
                        markdown: document.content,
                        theme: themeManager.currentTheme // Correct usage
                    )
                    .frame(minWidth: 400, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
                    .background(themeManager.currentTheme.editorBackground) // Correct usage
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

struct RichTextEditor: NSViewRepresentable {
    @Binding var text: String
    let theme: Theme

    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.delegate = context.coordinator
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width, .height]
        textView.backgroundColor = NSColor(theme.editorBackground)
        textView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.allowsUndo = true

        // Set the text color from the theme
        textView.textColor = NSColor(theme.editorTextColor) // Add this line

        return textView
    }

    func updateNSView(_ nsView: NSTextView, context: Context) {
        let attributedString = parseMarkdown(text, theme: theme)
        nsView.textStorage?.setAttributedString(attributedString)
        nsView.textColor = NSColor(theme.editorTextColor) //add this line.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor

        init(_ parent: RichTextEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            if let textView = notification.object as? NSTextView {
                parent.text = textView.attributedString().string
            }
        }
    }

    private func parseMarkdown(_ markdown: String, theme: Theme) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: markdown)
        let regexBold = try? NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*", options: [])
        let regexItalic = try? NSRegularExpression(pattern: "\\*(.*?)\\*", options: [])

        // Bold
        regexBold?.enumerateMatches(in: markdown, options: [], range: NSRange(location: 0, length: markdown.utf16.count)) { match, _, _ in
            if let match = match, let range = Range(match.range(at: 1), in: markdown) {
                let nsRange = NSRange(range, in: markdown)
                let font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
                let boldFont = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
                attributedString.addAttribute(.font, value: boldFont, range: nsRange)

                //Remove ** characters
                attributedString.replaceCharacters(in: NSRange(location: match.range.location, length: 2), with: "")
                let newLocation = match.range.location + match.range.length - 4;
                //Adjust the location due to the previous removal.
                attributedString.replaceCharacters(in: NSRange(location: newLocation - 2, length: 2), with: "")
            }
        }

        // Italic
        regexItalic?.enumerateMatches(in: markdown, options: [], range: NSRange(location: 0, length: markdown.utf16.count)) { match, _, _ in
            if let match = match, let range = Range(match.range(at: 1), in: markdown) {
                let nsRange = NSRange(range, in: markdown)
                let font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular) // Removed if let
                let italicFont = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
                attributedString.addAttribute(.font, value: italicFont, range: nsRange)

                //Remove * characters
                attributedString.replaceCharacters(in: NSRange(location: match.range.location, length: 1), with: "")
                let newLocation = match.range.location + match.range.length - 2;
                attributedString.replaceCharacters(in: NSRange(location: newLocation - 1, length: 1), with: "")
            }
        }
        return attributedString
    }
}
