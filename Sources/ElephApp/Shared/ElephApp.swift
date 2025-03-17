import SwiftUI
import ElephCore
import ElephThemes

// We are exporting this view so it can be used by the macOS and iOS app targets
public struct MainView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedDocument: Document?
    @State private var searchText = ""
    @State private var isShowingThemeSettings = false
    
    public init() {
        // Public initializer for external use
    }
    
    public var body: some View {
        NavigationSplitView {
            // Navigation pane (left)
            VStack {
                NavigationPane(
                    searchText: $searchText,
                    selectedDocument: $selectedDocument
                )
                
                Spacer()
                
                // Theme switcher button in the navigation pane
                Button(action: {
                    isShowingThemeSettings.toggle()
                }) {
                    Label("Theme Settings", systemImage: "paintpalette")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.bottom, 8)
                .popover(isPresented: $isShowingThemeSettings) {
                    ThemeSettingsView(themeManager: themeManager)
                        .frame(width: 300, height: 200)
                        .padding()
                }
            }
            .frame(minWidth: 200)
        } content: {
            // Preview pane (middle)
            if #available(macOS 13.0, iOS 16.0, *) {
                PreviewPane(
                    searchText: searchText,
                    selectedDocument: $selectedDocument
                )
                .frame(minWidth: 250)
            } else {
                PreviewPane(
                    searchText: searchText,
                    selectedDocument: $selectedDocument
                )
                .frame(minWidth: 250)
            }
        } detail: {
            // Editor/reading pane (right)
            if let document = selectedDocument {
                EditorPane(document: document)
            } else {
                VStack {
                    Image(systemName: "doc.text")
                        .font(.system(size: 72))
                        .foregroundColor(.gray)
                    Text("No Document Selected")
                        .font(.headline)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .applyTheme(themeManager.currentTheme)
    }
}