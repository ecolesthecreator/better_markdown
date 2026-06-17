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

    /// Extract plain text from all elements for copy functionality.
    ///
    /// Block-level elements (paragraphs, lists, headings, tables, nested
    /// quotes) are separated by a blank line so the pasted output mirrors
    /// the visual paragraph breaks that the user sees in the rendered
    /// blockquote. Within a list, items are separated by a single newline
    /// (and prefixed with their bullet/number) so the structure survives
    /// the round-trip too.
    private var plainText: String {
        elements.map { extractPlainText(from: $0) }
            .filter { !$0.isEmpty }
            .joined(separator: "\n\n")
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
        case .list(let items, let ordered):
            return renderListItems(items, ordered: ordered, indentLevel: 0)
        case .blockQuote(let nested):
            return nested.map { extractPlainText(from: $0) }
                .filter { !$0.isEmpty }
                .joined(separator: "\n\n")
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

    /// Render a flat list of items with bullet/number prefixes, recursing
    /// into nested items with two-space indentation per level. Items stay
    /// on adjacent lines (single `\n`) so a list still reads as one block
    /// when pasted.
    private func renderListItems(_ items: [ListItem], ordered: Bool, indentLevel: Int) -> String {
        let indent = String(repeating: "  ", count: indentLevel)
        return items.enumerated().map { index, item in
            let marker = ordered ? "\(index + 1). " : "- "
            var line = "\(indent)\(marker)\(item.content.plainText)"
            if !item.nestedItems.isEmpty {
                // Nested items inherit the parent's ordered flag — the
                // parser doesn't surface the nested list's own type here,
                // so we mirror the outer style. Good enough for paste.
                line += "\n" + renderListItems(item.nestedItems, ordered: ordered, indentLevel: indentLevel + 1)
            }
            return line
        }.joined(separator: "\n")
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
