import XCTest
@testable import BetterMarkdown

final class InlineCodeTests: XCTestCase {
    func testInlineCodeInHeading() throws {
        let markdown = """
        # Heading with `inline code`

        Regular paragraph with `inline code`.
        """

        let parsed = ParsedMarkdown(markdown: markdown)

        XCTAssertEqual(parsed.elements.count, 2)

        // Verify heading has inline code
        guard case .heading(let level, let content) = parsed.elements[0] else {
            XCTFail("Expected heading element")
            return
        }

        XCTAssertEqual(level, 1)
        XCTAssertTrue(content.contains { element in
            if case .inlineCode(let code) = element, code == "inline code" {
                return true
            }
            return false
        })
    }

    func testAttributedStringInlineCodeInHeading() throws {
        let markdown = "# Test `code` here"

        let attributed = AttributedStringRenderer.render(markdown: markdown)
        let string = attributed.string

        // Should contain the inline code text
        XCTAssertTrue(string.contains("code"))
        XCTAssertTrue(string.contains("Test"))
        XCTAssertTrue(string.contains("here"))
    }

    func testMultipleInlineCodeElements() throws {
        let markdown = "`first` and `second` code"

        let parsed = ParsedMarkdown(markdown: markdown)

        guard case .paragraph(let content) = parsed.elements[0] else {
            XCTFail("Expected paragraph element")
            return
        }

        let codeElements = content.compactMap { element -> String? in
            if case .inlineCode(let code) = element {
                return code
            }
            return nil
        }

        XCTAssertEqual(codeElements.count, 2)
        XCTAssertEqual(codeElements[0], "first")
        XCTAssertEqual(codeElements[1], "second")
    }
}
