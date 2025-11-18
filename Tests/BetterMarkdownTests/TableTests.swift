import XCTest
@testable import BetterMarkdown

final class TableTests: XCTestCase {
    func testTableParsing() throws {
        let markdown = """
        | Header 1 | Header 2 | Header 3 |
        |----------|----------|----------|
        | Cell 1   | Cell 2   | Cell 3   |
        | Cell 4   | Cell 5   | Cell 6   |
        """

        let parsed = ParsedMarkdown(markdown: markdown)

        XCTAssertEqual(parsed.elements.count, 1)

        guard case .table(let table) = parsed.elements[0] else {
            XCTFail("Expected table element")
            return
        }

        XCTAssertEqual(table.headers.count, 3)
        XCTAssertEqual(table.rows.count, 2)
        XCTAssertEqual(table.rows[0].count, 3)
    }

    func testTableWithAlignment() throws {
        let markdown = """
        | Left | Center | Right |
        |:-----|:------:|------:|
        | A    | B      | C     |
        """

        let parsed = ParsedMarkdown(markdown: markdown)

        guard case .table(let table) = parsed.elements[0] else {
            XCTFail("Expected table element")
            return
        }

        XCTAssertEqual(table.columnAlignments.count, 3)
        XCTAssertEqual(table.columnAlignments[0], .left)
        XCTAssertEqual(table.columnAlignments[1], .center)
        XCTAssertEqual(table.columnAlignments[2], .right)
    }

    func testAttributedStringTableRendering() throws {
        let markdown = """
        | Feature | Status |
        |---------|--------|
        | Tables  | ✅     |
        | Lists   | ✅     |
        """

        let attributed = AttributedStringRenderer.render(markdown: markdown)
        let string = attributed.string

        // Should contain box drawing characters
        XCTAssertTrue(string.contains("┌"))
        XCTAssertTrue(string.contains("─"))
        XCTAssertTrue(string.contains("│"))

        // Should contain the content
        XCTAssertTrue(string.contains("Feature"))
        XCTAssertTrue(string.contains("Status"))
        XCTAssertTrue(string.contains("Tables"))
    }
}
