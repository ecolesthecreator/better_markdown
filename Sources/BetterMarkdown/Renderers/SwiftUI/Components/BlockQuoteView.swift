import SwiftUI

/// Composite ID for ForEach that combines index and content
private struct ElementID: Hashable {
    let index: Int
    let element: MarkdownElement
}

/// Renders a block quote
struct BlockQuoteView: View {
    let elements: [MarkdownElement]
    let style: MarkdownStyle

    /// Extract plain text from all elements for copy functionality
    private var plainText: String {
        elements.map { extractPlainText(from: $0) }.joined(separator: "\n")
    }

    /// Recursively extract plain text from a MarkdownElement
    private func extractPlainText(from element: MarkdownElement) -> String {
        switch element {
        case .heading(_, let content):
            return content.plainText
        case .paragraph(let content):
            return content.plainText
        case .codeBlock(_, let code):
            return code
        case .list(let items, _):
            return items.map { $0.content.plainText }.joined(separator: "\n")
        case .blockQuote(let nested):
            return nested.map { extractPlainText(from: $0) }.joined(separator: "\n")
        case .table(let table):
            let headers = table.headers.map { $0.content.plainText }.joined(separator: "\t")
            let rows = table.rows.map { row in
                row.map { $0.content.plainText }.joined(separator: "\t")
            }.joined(separator: "\n")
            return [headers, rows].joined(separator: "\n")
        case .thematicBreak:
            return ""
        }
    }

    var body: some View {
        // Check if there's a custom renderer
        if let customView = style.customBlockquoteRenderer?(elements, style, plainText) {
            customView
        } else {
            defaultBlockquoteView
        }
    }

    @ViewBuilder
    private var defaultBlockquoteView: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left border
            Rectangle()
                .fill(style.blockQuoteBorderColor)
                .frame(width: 4)

            // Content
            VStack(alignment: .leading, spacing: 8) {
                ForEach(
                    Array(elements.enumerated().map { ElementID(index: $0, element: $1) }),
                    id: \.self
                ) { elementID in
                    MarkdownElementView(
                        element: elementID.element,
                        style: style,
                        isLastElement: elementID.index == elements.count - 1
                    )
                }
            }
            .padding(style.blockQuotePadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .fixedSize(horizontal: false, vertical: true)
        .background(style.blockQuoteBackgroundColor)
        .cornerRadius(4)
        .padding(.bottom, style.paragraphSpacing)
    }
}
