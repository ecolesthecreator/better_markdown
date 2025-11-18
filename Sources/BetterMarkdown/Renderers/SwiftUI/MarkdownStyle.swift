import SwiftUI

/// Style configuration for SwiftUI markdown rendering
public struct MarkdownStyle {
    // MARK: - Font Sizing

    /// Base font size - all other sizes are relative to this
    public var baseFontSize: CGFloat

    /// Scale factor applied to all fonts (useful for accessibility or user preferences)
    public var fontScale: CGFloat

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

    // MARK: - Initialization

    /// Create a MarkdownStyle with scalable fonts
    /// - Parameters:
    ///   - baseFontSize: Base font size (default is platform-specific)
    ///   - fontScale: Scale factor for all fonts (default 1.0)
    ///   - h1Font: Override H1 font (if nil, uses scaled default)
    ///   - h2Font: Override H2 font (if nil, uses scaled default)
    ///   - h3Font: Override H3 font (if nil, uses scaled default)
    ///   - h4Font: Override H4 font (if nil, uses scaled default)
    ///   - bodyFont: Override body font (if nil, uses scaled default)
    ///   - codeFont: Override code font (if nil, uses scaled default)
    public init(
        baseFontSize: CGFloat? = nil,
        fontScale: CGFloat = 1.0,
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
        syntaxHighlighter: SyntaxHighlighter? = nil
    ) {
        // Set base size and scale
        self.baseFontSize = baseFontSize ?? Self.defaultBaseFontSize
        self.fontScale = fontScale

        // Calculate scaled sizes
        let scaledBase = self.baseFontSize * fontScale
        let h1Size = scaledBase * 2.0   // 26pt at 13pt base (macOS), 34pt at 17pt base (iOS)
        let h2Size = scaledBase * 1.69  // 22pt at 13pt base (macOS), 29pt at 17pt base (iOS)
        let h3Size = scaledBase * 1.54  // 20pt at 13pt base (macOS), 26pt at 17pt base (iOS)
        let h4Size = scaledBase * 1.38  // 18pt at 13pt base (macOS), 23pt at 17pt base (iOS)

        // Use custom fonts or create scaled defaults
        self.h1Font = h1Font ?? .system(size: h1Size, weight: .bold)
        self.h2Font = h2Font ?? .system(size: h2Size, weight: .bold)
        self.h3Font = h3Font ?? .system(size: h3Size, weight: .semibold)
        self.h4Font = h4Font ?? .system(size: h4Size, weight: .semibold)
        self.bodyFont = bodyFont ?? .system(size: scaledBase)
        self.codeFont = codeFont ?? .system(size: scaledBase, design: .monospaced)

        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.codeBlockBackgroundColor = codeBlockBackgroundColor ?? Color.gray.opacity(0.2)
        self.codeBlockTextColor = codeBlockTextColor
        self.inlineCodeBackgroundColor = inlineCodeBackgroundColor ?? Color.gray.opacity(0.15)
        self.inlineCodeTextColor = inlineCodeTextColor ?? .pink
        self.blockQuoteBackgroundColor = blockQuoteBackgroundColor ?? Color.gray.opacity(0.1)
        self.blockQuoteBorderColor = blockQuoteBorderColor ?? Color.gray.opacity(0.6)
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
    }

    /// Default style configuration
    public static var `default`: MarkdownStyle {
        MarkdownStyle()
    }

    // MARK: - Platform Defaults

    /// Platform-dependent default base font size
    public static var defaultBaseFontSize: CGFloat {
        #if os(macOS)
        return 13
        #elseif os(iOS)
        return 17
        #elseif os(tvOS)
        return 29
        #elseif os(watchOS)
        return 16
        #else
        return 16
        #endif
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

    /// Create a scaled version of this style
    /// - Parameter scale: The scale factor to apply
    /// - Returns: A new MarkdownStyle with scaled fonts
    public func scaled(by scale: CGFloat) -> MarkdownStyle {
        MarkdownStyle(
            baseFontSize: baseFontSize,
            fontScale: fontScale * scale,
            textColor: textColor,
            backgroundColor: backgroundColor,
            codeBlockBackgroundColor: codeBlockBackgroundColor,
            codeBlockTextColor: codeBlockTextColor,
            inlineCodeBackgroundColor: inlineCodeBackgroundColor,
            inlineCodeTextColor: inlineCodeTextColor,
            blockQuoteBackgroundColor: blockQuoteBackgroundColor,
            blockQuoteBorderColor: blockQuoteBorderColor,
            tableHeaderBackgroundColor: tableHeaderBackgroundColor,
            tableRowBackgroundColor: tableRowBackgroundColor,
            tableAlternateRowBackgroundColor: tableAlternateRowBackgroundColor,
            tableBorderColor: tableBorderColor,
            headingSpacing: headingSpacing,
            paragraphSpacing: paragraphSpacing,
            listItemSpacing: listItemSpacing,
            codeBlockPadding: codeBlockPadding,
            inlineCodePadding: inlineCodePadding,
            blockQuotePadding: blockQuotePadding,
            tableCellPadding: tableCellPadding,
            syntaxHighlighter: syntaxHighlighter
        )
    }
}
