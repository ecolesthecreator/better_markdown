import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Protocol for syntax highlighting code blocks
public protocol SyntaxHighlighter {
    /// Highlight code with optional language specification
    /// - Parameters:
    ///   - code: The code to highlight
    ///   - language: Optional language identifier (e.g., "swift", "python", "javascript")
    /// - Returns: Highlighted code as NSAttributedString, or nil if highlighting failed
    func highlight(code: String, language: String?) -> NSAttributedString?
}

/// A pass-through highlighter that returns plain text without syntax highlighting
public struct PlainTextHighlighter: SyntaxHighlighter {
    private let font: PlatformFont
    private let textColor: PlatformColor

    public init(font: PlatformFont, textColor: PlatformColor) {
        self.font = font
        self.textColor = textColor
    }

    public func highlight(code: String, language: String?) -> NSAttributedString? {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        return NSAttributedString(string: code, attributes: attributes)
    }
}

// MARK: - Platform Compatibility

#if canImport(UIKit)
public typealias PlatformFont = UIFont
public typealias PlatformColor = UIColor
#elseif canImport(AppKit)
public typealias PlatformFont = NSFont
public typealias PlatformColor = NSColor
#endif
