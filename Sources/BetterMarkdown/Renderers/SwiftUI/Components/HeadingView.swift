import SwiftUI

/// Renders a markdown heading
struct HeadingView: View {
    let level: Int
    let content: [InlineElement]
    let style: MarkdownStyle

    var body: some View {
        InlineTextView(elements: content, style: style)
            .font(style.font(forHeadingLevel: level))
            .padding(.bottom, style.headingSpacing)
    }
}
