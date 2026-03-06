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

    var body: some View {
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
