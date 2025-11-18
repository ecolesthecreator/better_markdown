import SwiftUI

/// Renders a single markdown block element
struct MarkdownElementView: View {
    let element: MarkdownElement
    let style: MarkdownStyle
    let isLastElement: Bool

    var body: some View {
        switch element {
        case .heading(let level, let content):
            HeadingView(level: level, content: content, style: style)

        case .paragraph(let content):
            InlineTextView(elements: content, style: style)
                .font(style.bodyFont)
                .padding(.bottom, isLastElement ? 0 : style.paragraphSpacing)

        case .codeBlock(let language, let code):
            CodeBlockView(language: language, code: code, style: style)

        case .list(let items, let ordered):
            ListItemView(items: items, ordered: ordered, style: style)

        case .blockQuote(let elements):
            BlockQuoteView(elements: elements, style: style)

        case .table(let table):
            TableView(table: table, style: style)

        case .thematicBreak:
            Divider()
                .padding(.vertical, style.paragraphSpacing)
        }
    }
}
