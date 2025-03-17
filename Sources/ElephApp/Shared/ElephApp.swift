import SwiftUI
import ElephCore
import ElephThemes

// We are exporting this view so it canbe used by the macOS and iOS app targets
public struct MainView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedDocument: Document?
    @State private var searchText = ""

    public init() {}

    public var body: some View {
        NavigationSplitView {
            NavigationPane(
                searchText: $searchText,
                selectedDocument: $selectedDocument
            ) // Removed searchText binding.
            .frame(minWidth: 200)
        } content: {
            PreviewPane(
                searchText: searchText, // Still used here.
                selectedDocument: $selectedDocument
            )
            .frame(minWidth: 250)
        } detail: {
            if let document = selectedDocument {
                EditorPane(document: document)
            } else {
                // ...
            }
        }
        .navigationSplitViewStyle(.balanced)
        .applyTheme(themeManager.currentTheme)
    }
}
