import SwiftUI

/// Renders a list (ordered or unordered)
struct ListItemView: View {
    let items: [ListItem]
    let ordered: Bool
    let style: MarkdownStyle
    let startIndex: Int

    init(items: [ListItem], ordered: Bool, style: MarkdownStyle, startIndex: Int = 1) {
        self.items = items
        self.ordered = ordered
        self.style = style
        self.startIndex = startIndex
    }

    var body: some View {
        VStack(alignment: .leading, spacing: style.listItemSpacing) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 8) {
                    // Bullet or number
                    Text(bulletText(for: index))
                        .font(style.bodyFont)
                        .foregroundColor(style.textColor)
                        .frame(width: 20, alignment: .trailing)

                    VStack(alignment: .leading, spacing: 4) {
                        // Item content (the first paragraph's inline text)
                        if !item.content.isEmpty {
                            InlineTextView(elements: item.content, style: style)
                        }

                        // Additional block-level children (code blocks, secondary
                        // paragraphs, block quotes, tables, etc.) that appeared
                        // inside the same list item.
                        if !item.blocks.isEmpty {
                            ForEach(Array(item.blocks.enumerated()), id: \.offset) { blockIndex, block in
                                MarkdownElementView(
                                    element: block,
                                    style: style,
                                    isLastElement: blockIndex == item.blocks.count - 1 && item.nestedItems.isEmpty
                                )
                            }
                        }

                        // Nested items
                        if !item.nestedItems.isEmpty {
                            ListItemView(
                                items: item.nestedItems,
                                ordered: ordered,
                                style: style,
                                startIndex: 1
                            )
                            .padding(.leading, 20)
                        }
                    }
                }
            }
        }
        .padding(.bottom, style.paragraphSpacing)
    }

    private func bulletText(for index: Int) -> String {
        if ordered {
            return "\(startIndex + index)."
        } else {
            return "•"
        }
    }
}
