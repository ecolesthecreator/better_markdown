import SwiftUI

/// Style configuration for SwiftUI markdown rendering
public struct MarkdownStyle {
    // MARK: - Typography

    public var h1Font: Font
    public var h2Font: Font
    public var h3Font: Font
    public var h4Font: Font
    public var bodyFont: Font
    public var codeFont: Font

    // MARK: - Colors

    public var textColor: Color
    public var backgroundColor: Color
    public var codeBlockBackgroundColor: Color
    public var codeBlockTextColor: Color
    public var inlineCodeBackgroundColor: Color
    public var inlineCodeTextColor: Color
    public var blockQuoteBackgroundColor: Color
    public var blockQuoteBorderColor: Color
    public var linkColor: Color
    public var tableHeaderBackgroundColor: Color
    public var tableRowBackgroundColor: Color
    public var tableAlternateRowBackgroundColor: Color
    public var tableBorderColor: Color

    // MARK: - Spacing

    public var headingSpacing: CGFloat
    public var paragraphSpacing: CGFloat
    public var listItemSpacing: CGFloat
    public var codeBlockPadding: EdgeInsets
    public var inlineCodePadding: EdgeInsets
    public var blockQuotePadding: EdgeInsets
    public var tableCellPadding: EdgeInsets

    // MARK: - Code Highlighting

    /// Optional syntax highlighter for code blocks (used by NSAttributedString renderer)
    public var syntaxHighlighter: SyntaxHighlighter?

    /// Optional custom code block renderer (e.g., for mermaid diagrams)
    /// Return a view for languages you want to custom-render, or nil to use default code block rendering
    /// Parameters: (language: String?, code: String) -> AnyView?
    public var customCodeBlockRenderer: ((String?, String) -> AnyView?)?

    /// Optional custom blockquote renderer (e.g., for adding copy functionality)
    /// Return a view for custom blockquote rendering, or nil to use default rendering
    /// Parameters: (elements: [MarkdownElement], style: MarkdownStyle, plainText: String) -> AnyView?
    public var customBlockquoteRenderer: (([MarkdownElement], MarkdownStyle, String) -> AnyView?)?

    // MARK: - Initialization

    /// Create a MarkdownStyle with Apple's standard text styles
    /// - Parameters:
    ///   - h1Font: Override H1 font (if nil, uses .title)
    ///   - h2Font: Override H2 font (if nil, uses .title2)
    ///   - h3Font: Override H3 font (if nil, uses .title3)
    ///   - h4Font: Override H4 font (if nil, uses .headline)
    ///   - bodyFont: Override body font (if nil, uses .body)
    ///   - codeFont: Override code font (if nil, uses .body.monospaced())
    public init(
        h1Font: Font? = nil,
        h2Font: Font? = nil,
        h3Font: Font? = nil,
        h4Font: Font? = nil,
        bodyFont: Font? = nil,
        codeFont: Font? = nil,
        textColor: Color = .primary,
        backgroundColor: Color = .clear,
        codeBlockBackgroundColor: Color? = nil,
        codeBlockTextColor: Color = .primary,
        inlineCodeBackgroundColor: Color? = nil,
        inlineCodeTextColor: Color? = nil,
        blockQuoteBackgroundColor: Color? = nil,
        blockQuoteBorderColor: Color? = nil,
        linkColor: Color? = nil,
        tableHeaderBackgroundColor: Color? = nil,
        tableRowBackgroundColor: Color? = nil,
        tableAlternateRowBackgroundColor: Color? = nil,
        tableBorderColor: Color? = nil,
        headingSpacing: CGFloat = 8,
        paragraphSpacing: CGFloat = 12,
        listItemSpacing: CGFloat = 4,
        codeBlockPadding: EdgeInsets = EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12),
        inlineCodePadding: EdgeInsets = EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4),
        blockQuotePadding: EdgeInsets = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12),
        tableCellPadding: EdgeInsets = EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12),
        syntaxHighlighter: SyntaxHighlighter? = nil,
        customCodeBlockRenderer: ((String?, String) -> AnyView?)? = nil,
        customBlockquoteRenderer: (([MarkdownElement], MarkdownStyle, String) -> AnyView?)? = nil
    ) {
        // Use Apple's standard text styles for headings (familiar to users)
        // H1 -> .title (bold), H2 -> .title2 (bold), H3 -> .title3 (bold), H4 -> .headline
        self.h1Font = h1Font ?? .title.weight(.bold)
        self.h2Font = h2Font ?? .title2.weight(.bold)
        self.h3Font = h3Font ?? .title3.weight(.bold)
        self.h4Font = h4Font ?? .headline
        self.bodyFont = bodyFont ?? .body
        self.codeFont = codeFont ?? .body.monospaced()

        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.codeBlockBackgroundColor = codeBlockBackgroundColor ?? Color.gray.opacity(0.2)
        self.codeBlockTextColor = codeBlockTextColor
        self.inlineCodeBackgroundColor = inlineCodeBackgroundColor ?? Color.gray.opacity(0.15)
        self.inlineCodeTextColor = inlineCodeTextColor ?? .pink
        self.blockQuoteBackgroundColor = blockQuoteBackgroundColor ?? Color.gray.opacity(0.1)
        self.blockQuoteBorderColor = blockQuoteBorderColor ?? Color.gray.opacity(0.6)
        self.linkColor = linkColor ?? .blue
        self.tableHeaderBackgroundColor = tableHeaderBackgroundColor ?? Color.gray.opacity(0.15)
        self.tableRowBackgroundColor = tableRowBackgroundColor ?? Color.clear
        self.tableAlternateRowBackgroundColor = tableAlternateRowBackgroundColor ?? Color.gray.opacity(0.05)
        self.tableBorderColor = tableBorderColor ?? Color.gray.opacity(0.3)
        self.headingSpacing = headingSpacing
        self.paragraphSpacing = paragraphSpacing
        self.listItemSpacing = listItemSpacing
        self.codeBlockPadding = codeBlockPadding
        self.inlineCodePadding = inlineCodePadding
        self.blockQuotePadding = blockQuotePadding
        self.tableCellPadding = tableCellPadding
        self.syntaxHighlighter = syntaxHighlighter
        self.customCodeBlockRenderer = customCodeBlockRenderer
        self.customBlockquoteRenderer = customBlockquoteRenderer
    }

    /// Default style configuration using Apple's text styles
    public static var `default`: MarkdownStyle {
        MarkdownStyle()
    }

    // MARK: - Font Helpers

    /// Get the font for a heading level
    public func font(forHeadingLevel level: Int) -> Font {
        switch level {
        case 1: return h1Font
        case 2: return h2Font
        case 3: return h3Font
        case 4: return h4Font
        default: return bodyFont
        }
    }

}
