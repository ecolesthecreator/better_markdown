import SwiftUI

/// Composite ID for ForEach that combines index and content
private struct ElementID: Hashable {
    let index: Int
    let element: MarkdownElement
}

/// Main SwiftUI view for rendering markdown
public struct MarkdownView: View {
    private let parsed: ParsedMarkdown
    private let style: MarkdownStyle

    /// Create a MarkdownView from pre-parsed markdown
    /// - Parameters:
    ///   - parsed: Pre-parsed markdown structure
    ///   - style: Style configuration for rendering
    public init(parsed: ParsedMarkdown, style: MarkdownStyle = .default) {
        self.parsed = parsed
        self.style = style
    }

    /// Create a MarkdownView from a markdown string
    /// - Parameters:
    ///   - markdown: Raw markdown string to parse and render
    ///   - style: Style configuration for rendering
    public init(markdown: String, style: MarkdownStyle = .default) {
        self.parsed = ParsedMarkdown(markdown: markdown)
        self.style = style
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(
                Array(parsed.elements.enumerated().map { ElementID(index: $0, element: $1) }),
                id: \.self
            ) { elementID in
                MarkdownElementView(
                    element: elementID.element,
                    style: style,
                    isLastElement: elementID.index == parsed.elements.count - 1
                )
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(style.backgroundColor)
    }
}

// MARK: - Previews

#if DEBUG
struct MarkdownView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            MarkdownView(markdown: sampleMarkdown)
                .padding()
        }
    }

    static let sampleMarkdown = """
    # Heading 1
    This is a paragraph with **bold text**, *italic text*, and `inline code`.

    ## Heading 2
    Here's another paragraph with ~~strikethrough~~.

    ### Code Block
    ```swift
    let greeting = "Hello, World!"
    print(greeting)
    ```

    ### Lists
    - First item
    - Second item
    - Third item

    ### Block Quote
    > This is a block quote.
    > It can span multiple lines.

    ---

    That's all!
    """
}
#endif
