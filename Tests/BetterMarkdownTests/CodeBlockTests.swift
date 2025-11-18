import XCTest
@testable import BetterMarkdown

final class CodeBlockTests: XCTestCase {
    func testCodeBlockParsing() throws {
        let markdown = """
        ```swift
        let x = 42
        print(x)
        ```
        """

        let parsed = ParsedMarkdown(markdown: markdown)

        XCTAssertEqual(parsed.elements.count, 1)

        guard case .codeBlock(let language, let code) = parsed.elements[0] else {
            XCTFail("Expected code block element")
            return
        }

        XCTAssertEqual(language, "swift")
        XCTAssertTrue(code.contains("let x = 42"))
        XCTAssertTrue(code.contains("print(x)"))
    }

    func testCodeBlockWithoutLanguage() throws {
        let markdown = """
        ```
        plain code
        ```
        """

        let parsed = ParsedMarkdown(markdown: markdown)

        guard case .codeBlock(let language, let code) = parsed.elements[0] else {
            XCTFail("Expected code block element")
            return
        }

        XCTAssertNil(language)
        XCTAssertEqual(code.trimmingCharacters(in: .whitespacesAndNewlines), "plain code")
    }

    func testAttributedStringCodeBlock() throws {
        let markdown = """
        ```python
        def hello():
            print("world")
        ```
        """

        let attributed = AttributedStringRenderer.render(markdown: markdown)
        let string = attributed.string

        // Should contain the code
        XCTAssertTrue(string.contains("def hello()"))
        XCTAssertTrue(string.contains("print(\"world\")"))
    }
}
