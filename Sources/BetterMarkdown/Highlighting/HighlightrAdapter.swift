import Foundation
import Highlightr

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Adapter for Highlightr library providing syntax highlighting
public class HighlightrAdapter: SyntaxHighlighter {
    private let highlightr: Highlightr
    private let fallbackFont: PlatformFont
    private let fallbackColor: PlatformColor

    /// Create a Highlightr adapter
    /// - Parameters:
    ///   - theme: The color theme to use (e.g., "xcode", "monokai", "github")
    ///   - fallbackFont: Font to use when highlighting fails
    ///   - fallbackColor: Text color to use when highlighting fails
    public init?(
        theme: String = "xcode",
        fallbackFont: PlatformFont? = nil,
        fallbackColor: PlatformColor? = nil
    ) {
        guard let highlightr = Highlightr() else {
            return nil
        }

        self.highlightr = highlightr
        self.fallbackFont = fallbackFont ?? .monospacedSystemFont(ofSize: 14, weight: .regular)
        self.fallbackColor = fallbackColor ?? .label

        highlightr.setTheme(to: theme)
    }

    /// Set the color theme
    public func setTheme(_ theme: String) {
        highlightr.setTheme(to: theme)
    }

    /// Get available themes
    public var availableThemes: [String] {
        highlightr.availableThemes()
    }

    public func highlight(code: String, language: String?) -> NSAttributedString? {
        // If language is specified, try to highlight with that language
        if let language = language,
           let highlighted = highlightr.highlight(code, as: language) {
            return highlighted
        }

        // If no language or highlighting failed, try auto-detection
        if let highlighted = highlightr.highlight(code) {
            return highlighted
        }

        // Fallback to plain text
        let attributes: [NSAttributedString.Key: Any] = [
            .font: fallbackFont,
            .foregroundColor: fallbackColor
        ]
        return NSAttributedString(string: code, attributes: attributes)
    }
}

#if canImport(UIKit)
extension UIColor {
    static var label: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }
}
#elseif canImport(AppKit)
extension NSColor {
    static var label: NSColor {
        if #available(macOS 10.14, *) {
            return .labelColor
        } else {
            return .black
        }
    }
}
#endif
