import SwiftUI
import ElephCore
import ElephThemes

// We are exporting this view so it can be used by the macOS and iOS app targets
public struct MainView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedDocument: Document?
    @State private var searchText = ""
    @Environment(\.scenePhase) private var scenePhase

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
                // EditorPane(document: document)
                EditorPaneExampleView()
            } else {
                EmptyView()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .applyTheme(themeManager.currentTheme)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background || newPhase == .inactive {
                // Save current document when app goes to background or becomes inactive
                saveCurrentDocument()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SaveAllDocuments"))) { _ in
            // Save current document when we receive the save notification
            saveCurrentDocument()
        }
    }
    
    private func saveCurrentDocument() {
        // guard let document = selectedDocument else { return }
        
        // Just call the direct save method
        // document.save()
    }
}

// App delegate to handle application lifecycle events for macOS
#if os(macOS)
public class AppDelegate: NSObject, NSApplicationDelegate {
    public func applicationWillTerminate(_ notification: Notification) {
        // Force save all open documents
        NotificationCenter.default.post(name: NSNotification.Name("SaveAllDocuments"), object: nil)
    }
}
#endif
