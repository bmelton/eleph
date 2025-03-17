import XCTest
@testable import ElephCore

final class DocumentTests: XCTestCase {
    func testDocumentInitialization() {
        let document = Document(title: "Test Document", content: "# Test Content")
        
        XCTAssertEqual(document.title, "Test Document")
        XCTAssertEqual(document.content, "# Test Content")
        XCTAssertTrue(document.tags.isEmpty)
    }
    
    func testPreviewText() {
        let document = Document(
            title: "Test",
            content: "# Heading\n\n*Italic* text and **bold** text."
        )
        
        let preview = document.previewText
        XCTAssertFalse(preview.contains("#"))
        XCTAssertFalse(preview.contains("*"))
    }
}