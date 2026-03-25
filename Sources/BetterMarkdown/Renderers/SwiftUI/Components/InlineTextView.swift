import SwiftUI

/// Renders inline markdown elements (text with formatting)
struct InlineTextView: View {
    let elements: [InlineElement]
    let style: MarkdownStyle

    var body: some View {
        elements.map { element in
            renderInlineElement(element)
        }.reduce(Text(""), +)
            .foregroundColor(style.textColor)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func renderInlineElement(_ element: InlineElement) -> Text {
        switch element {
        case .text(let string):
            return Text(string)

        case .strong(let children):
            return children.map { renderInlineElement($0) }
                .reduce(Text(""), +)
                .bold()

        case .emphasis(let children):
            return children.map { renderInlineElement($0) }
                .reduce(Text(""), +)
                .italic()

        case .strikethrough(let children):
            return children.map { renderInlineElement($0) }
                .reduce(Text(""), +)
                .strikethrough()

        case .inlineCode(let code):
            // Use fontDesign to maintain heading size while being monospaced
            // Falls back to codeFont for older versions
            if #available(macOS 13.0, iOS 16.1, tvOS 16.1, watchOS 9.1, *) {
                return Text(code)
                    .fontDesign(.monospaced)
                    .foregroundColor(style.inlineCodeTextColor)
            } else {
                return Text(code)
                    .font(style.codeFont)
                    .foregroundColor(style.inlineCodeTextColor)
            }

        case .link(let destination, let children):
            let plainText = children.map { $0.plainText }.joined()
            if let url = URL(string: destination) {
                var attributedString = AttributedString(plainText)
                attributedString.link = url
                attributedString.foregroundColor = style.linkColor
                return Text(attributedString)
            } else {
                return Text(plainText)
                    .foregroundColor(style.linkColor)
                    .underline(color: style.linkColor)
            }

        case .softBreak:
            return Text("\n")

        case .lineBreak:
            return Text("\n")
        }
    }
}
