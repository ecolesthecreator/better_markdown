import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Style configuration for NSAttributedString markdown rendering
public struct AttributedStringStyle {
    // MARK: - Font Sizing

    /// Base font size - all other sizes are relative to this
    public var baseFontSize: CGFloat

    /// Scale factor applied to all fonts (useful for accessibility or user preferences)
    public var fontScale: CGFloat

    // MARK: - Typography

    public var h1Font: PlatformFont
    public var h2Font: PlatformFont
    public var h3Font: PlatformFont
    public var h4Font: PlatformFont
    public var bodyFont: PlatformFont
    public var codeFont: PlatformFont

    // MARK: - Colors

    public var textColor: PlatformColor
    public var backgroundColor: PlatformColor
    public var codeBlockBackgroundColor: PlatformColor
    public var codeBlockTextColor: PlatformColor
    public var inlineCodeBackgroundColor: PlatformColor
    public var inlineCodeTextColor: PlatformColor
    public var blockQuoteBackgroundColor: PlatformColor
    public var blockQuoteBorderColor: PlatformColor
    public var linkColor: PlatformColor

    // MARK: - Spacing

    public var headingSpacing: CGFloat
    public var paragraphSpacing: CGFloat
    public var listItemSpacing: CGFloat
    public var listIndentation: CGFloat

    // MARK: - Code Highlighting

    public var syntaxHighlighter: SyntaxHighlighter?

    // MARK: - Initialization

    /// Create an AttributedStringStyle with scalable fonts
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
        h1Font: PlatformFont? = nil,
        h2Font: PlatformFont? = nil,
        h3Font: PlatformFont? = nil,
        h4Font: PlatformFont? = nil,
        bodyFont: PlatformFont? = nil,
        codeFont: PlatformFont? = nil,
        textColor: PlatformColor? = nil,
        backgroundColor: PlatformColor = .clear,
        codeBlockBackgroundColor: PlatformColor? = nil,
        codeBlockTextColor: PlatformColor? = nil,
        inlineCodeBackgroundColor: PlatformColor? = nil,
        inlineCodeTextColor: PlatformColor? = nil,
        blockQuoteBackgroundColor: PlatformColor? = nil,
        blockQuoteBorderColor: PlatformColor? = nil,
        linkColor: PlatformColor? = nil,
        headingSpacing: CGFloat = 8,
        paragraphSpacing: CGFloat = 12,
        listItemSpacing: CGFloat = 4,
        listIndentation: CGFloat = 20,
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
        let codeSize = scaledBase * 0.94  // Slightly smaller for code

        #if canImport(UIKit)
        self.h1Font = h1Font ?? .systemFont(ofSize: h1Size, weight: .bold)
        self.h2Font = h2Font ?? .systemFont(ofSize: h2Size, weight: .bold)
        self.h3Font = h3Font ?? .systemFont(ofSize: h3Size, weight: .semibold)
        self.h4Font = h4Font ?? .systemFont(ofSize: h4Size, weight: .semibold)
        self.bodyFont = bodyFont ?? .systemFont(ofSize: scaledBase)
        self.codeFont = codeFont ?? .monospacedSystemFont(ofSize: codeSize, weight: .regular)

        self.textColor = textColor ?? .label
        self.codeBlockBackgroundColor = codeBlockBackgroundColor ?? .compatSystemGray6
        self.codeBlockTextColor = codeBlockTextColor ?? .label
        self.inlineCodeBackgroundColor = inlineCodeBackgroundColor ?? .compatSystemGray5
        self.inlineCodeTextColor = inlineCodeTextColor ?? .compatSystemPink
        self.blockQuoteBackgroundColor = blockQuoteBackgroundColor ?? .compatSystemGray6.withAlphaComponent(0.5)
        self.blockQuoteBorderColor = blockQuoteBorderColor ?? .compatSystemGray3
        self.linkColor = linkColor ?? .systemBlue
        #elseif canImport(AppKit)
        self.h1Font = h1Font ?? .systemFont(ofSize: h1Size, weight: .bold)
        self.h2Font = h2Font ?? .systemFont(ofSize: h2Size, weight: .bold)
        self.h3Font = h3Font ?? .systemFont(ofSize: h3Size, weight: .semibold)
        self.h4Font = h4Font ?? .systemFont(ofSize: h4Size, weight: .semibold)
        self.bodyFont = bodyFont ?? .systemFont(ofSize: scaledBase)
        self.codeFont = codeFont ?? .monospacedSystemFont(ofSize: codeSize, weight: .regular)

        self.textColor = textColor ?? .label
        self.codeBlockBackgroundColor = codeBlockBackgroundColor ?? .compatSystemGray6
        self.codeBlockTextColor = codeBlockTextColor ?? .label
        self.inlineCodeBackgroundColor = inlineCodeBackgroundColor ?? .compatSystemGray5
        self.inlineCodeTextColor = inlineCodeTextColor ?? .compatSystemPink
        self.blockQuoteBackgroundColor = blockQuoteBackgroundColor ?? .compatSystemGray6.withAlphaComponent(0.5)
        self.blockQuoteBorderColor = blockQuoteBorderColor ?? .compatSystemGray3
        self.linkColor = linkColor ?? .systemBlue
        #endif

        self.backgroundColor = backgroundColor
        self.headingSpacing = headingSpacing
        self.paragraphSpacing = paragraphSpacing
        self.listItemSpacing = listItemSpacing
        self.listIndentation = listIndentation
        self.syntaxHighlighter = syntaxHighlighter
    }

    /// Default style configuration
    public static var `default`: AttributedStringStyle {
        AttributedStringStyle()
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
    public func font(forHeadingLevel level: Int) -> PlatformFont {
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
    /// - Returns: A new AttributedStringStyle with scaled fonts
    public func scaled(by scale: CGFloat) -> AttributedStringStyle {
        AttributedStringStyle(
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
            linkColor: linkColor,
            headingSpacing: headingSpacing,
            paragraphSpacing: paragraphSpacing,
            listItemSpacing: listItemSpacing,
            listIndentation: listIndentation,
            syntaxHighlighter: syntaxHighlighter
        )
    }
}

// MARK: - Platform Extensions

#if canImport(UIKit)
extension UIColor {
    public static var compatSystemGray3: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray3
        } else {
            return UIColor(white: 0.78, alpha: 1.0)
        }
    }

    public static var compatSystemGray5: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray5
        } else {
            return UIColor(white: 0.90, alpha: 1.0)
        }
    }

    public static var compatSystemGray6: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray6
        } else {
            return UIColor(white: 0.95, alpha: 1.0)
        }
    }

    public static var compatSystemPink: UIColor {
        if #available(iOS 13.0, *) {
            return .systemPink
        } else {
            return UIColor(red: 1.0, green: 0.176, blue: 0.333, alpha: 1.0)
        }
    }
}
#elseif canImport(AppKit)
extension NSColor {
    public static var compatSystemGray3: NSColor {
        if #available(macOS 10.14, *) {
            return .systemGray
        } else {
            return NSColor(white: 0.78, alpha: 1.0)
        }
    }

    public static var compatSystemGray5: NSColor {
        if #available(macOS 10.14, *) {
            return .systemGray
        } else {
            return NSColor(white: 0.90, alpha: 1.0)
        }
    }

    public static var compatSystemGray6: NSColor {
        if #available(macOS 10.14, *) {
            return .systemGray
        } else {
            return NSColor(white: 0.95, alpha: 1.0)
        }
    }

    public static var compatSystemPink: NSColor {
        if #available(macOS 10.14, *) {
            return .systemPink
        } else {
            return NSColor(red: 1.0, green: 0.176, blue: 0.333, alpha: 1.0)
        }
    }
}
#endif
