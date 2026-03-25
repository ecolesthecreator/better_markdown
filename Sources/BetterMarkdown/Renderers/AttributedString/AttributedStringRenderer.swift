import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Renderer that converts parsed markdown to NSAttributedString
public class AttributedStringRenderer {
    private let style: AttributedStringStyle

    public init(style: AttributedStringStyle = .default) {
        self.style = style
    }

    // MARK: - Public API

    /// Render parsed markdown to NSAttributedString
    public func render(_ parsed: ParsedMarkdown) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for element in parsed.elements {
            let elementString = renderElement(element)
            result.append(elementString)
        }

        return result
    }

    /// Render markdown string to NSAttributedString
    public static func render(markdown: String, style: AttributedStringStyle = .default) -> NSAttributedString {
        let parsed = ParsedMarkdown(markdown: markdown)
        let renderer = AttributedStringRenderer(style: style)
        return renderer.render(parsed)
    }

    /// Render pre-parsed markdown to NSAttributedString
    public static func render(parsed: ParsedMarkdown, style: AttributedStringStyle = .default) -> NSAttributedString {
        let renderer = AttributedStringRenderer(style: style)
        return renderer.render(parsed)
    }

    // MARK: - Block Element Rendering

    private func renderElement(_ element: MarkdownElement) -> NSAttributedString {
        switch element {
        case .heading(let level, let content):
            return renderHeading(level: level, content: content)

        case .paragraph(let content):
            return renderParagraph(content: content)

        case .codeBlock(let language, let code):
            return renderCodeBlock(language: language, code: code)

        case .list(let items, let ordered):
            return renderList(items: items, ordered: ordered, indentLevel: 0)

        case .blockQuote(let elements):
            return renderBlockQuote(elements: elements)

        case .table(let table):
            return renderTable(table: table)

        case .thematicBreak:
            return renderThematicBreak()
        }
    }

    private func renderHeading(level: Int, content: [InlineElement]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let font = style.font(forHeadingLevel: level)
        let inlineString = renderInlineElements(content, baseFont: font)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = style.headingSpacing

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: style.textColor,
            .paragraphStyle: paragraphStyle
        ]

        let headingString = NSMutableAttributedString(attributedString: inlineString)
        headingString.addAttributes(attributes, range: NSRange(location: 0, length: headingString.length))
        headingString.append(NSAttributedString(string: "\n"))

        result.append(headingString)
        return result
    }

    private func renderParagraph(content: [InlineElement]) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let inlineString = renderInlineElements(content)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = style.paragraphSpacing

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle
        ]

        let paragraphString = NSMutableAttributedString(attributedString: inlineString)
        paragraphString.addAttributes(attributes, range: NSRange(location: 0, length: paragraphString.length))
        paragraphString.append(NSAttributedString(string: "\n"))

        result.append(paragraphString)
        return result
    }

    private func renderCodeBlock(language: String?, code: String) -> NSAttributedString {
        let result = NSMutableAttributedString()

        // Try syntax highlighting first
        if let highlighter = style.syntaxHighlighter,
           let highlighted = highlighter.highlight(code: code, language: language) {
            result.append(highlighted)
        } else {
            // Fallback to plain text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: style.codeFont,
                .foregroundColor: style.codeBlockTextColor,
                .backgroundColor: style.codeBlockBackgroundColor
            ]
            result.append(NSAttributedString(string: code, attributes: attributes))
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = style.paragraphSpacing
        result.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: result.length))
        result.append(NSAttributedString(string: "\n"))

        return result
    }

    private func renderList(items: [ListItem], ordered: Bool, indentLevel: Int) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for (index, item) in items.enumerated() {
            let bullet = ordered ? "\(index + 1). " : "• "
            let indent = String(repeating: " ", count: indentLevel * 4)

            let bulletAttributes: [NSAttributedString.Key: Any] = [
                .font: style.bodyFont,
                .foregroundColor: style.textColor
            ]

            result.append(NSAttributedString(string: indent + bullet, attributes: bulletAttributes))
            result.append(renderInlineElements(item.content))
            result.append(NSAttributedString(string: "\n"))

            // Render nested items
            if !item.nestedItems.isEmpty {
                let nestedList = renderList(items: item.nestedItems, ordered: ordered, indentLevel: indentLevel + 1)
                result.append(nestedList)
            }
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = style.paragraphSpacing
        result.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: result.length))

        return result
    }

    private func renderBlockQuote(elements: [MarkdownElement]) -> NSAttributedString {
        let result = NSMutableAttributedString()

        for element in elements {
            result.append(renderElement(element))
        }

        // Add background color and indentation
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 20
        paragraphStyle.firstLineHeadIndent = 20

        result.addAttributes([
            .backgroundColor: style.blockQuoteBackgroundColor,
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: result.length))

        return result
    }

    private func renderThematicBreak() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = style.paragraphSpacing

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: style.textColor
        ]

        return NSAttributedString(string: "───────────────────\n", attributes: attributes)
    }

    private func renderTable(table: Table) -> NSAttributedString {
        let result = NSMutableAttributedString()

        // Render header row
        result.append(NSAttributedString(string: "┌", attributes: [.font: style.bodyFont]))
        for (index, _) in table.headers.enumerated() {
            result.append(NSAttributedString(string: "───────", attributes: [.font: style.bodyFont]))
            if index < table.headers.count - 1 {
                result.append(NSAttributedString(string: "┬", attributes: [.font: style.bodyFont]))
            }
        }
        result.append(NSAttributedString(string: "┐\n", attributes: [.font: style.bodyFont]))

        // Header cells
        result.append(NSAttributedString(string: "│ ", attributes: [.font: style.bodyFont]))
        for (index, cell) in table.headers.enumerated() {
            result.append(renderInlineElements(cell.content))
            result.append(NSAttributedString(string: index < table.headers.count - 1 ? " │ " : " │\n", attributes: [.font: style.bodyFont]))
        }

        // Header separator
        result.append(NSAttributedString(string: "├", attributes: [.font: style.bodyFont]))
        for (index, _) in table.headers.enumerated() {
            result.append(NSAttributedString(string: "───────", attributes: [.font: style.bodyFont]))
            if index < table.headers.count - 1 {
                result.append(NSAttributedString(string: "┼", attributes: [.font: style.bodyFont]))
            }
        }
        result.append(NSAttributedString(string: "┤\n", attributes: [.font: style.bodyFont]))

        // Body rows
        for (rowIndex, row) in table.rows.enumerated() {
            result.append(NSAttributedString(string: "│ ", attributes: [.font: style.bodyFont]))
            for (colIndex, cell) in row.enumerated() {
                result.append(renderInlineElements(cell.content))
                result.append(NSAttributedString(string: colIndex < row.count - 1 ? " │ " : " │\n", attributes: [.font: style.bodyFont]))
            }

            // Row separator (not after last row)
            if rowIndex < table.rows.count - 1 {
                result.append(NSAttributedString(string: "├", attributes: [.font: style.bodyFont]))
                for (index, _) in table.headers.enumerated() {
                    result.append(NSAttributedString(string: "───────", attributes: [.font: style.bodyFont]))
                    if index < table.headers.count - 1 {
                        result.append(NSAttributedString(string: "┼", attributes: [.font: style.bodyFont]))
                    }
                }
                result.append(NSAttributedString(string: "┤\n", attributes: [.font: style.bodyFont]))
            }
        }

        // Bottom border
        result.append(NSAttributedString(string: "└", attributes: [.font: style.bodyFont]))
        for (index, _) in table.headers.enumerated() {
            result.append(NSAttributedString(string: "───────", attributes: [.font: style.bodyFont]))
            if index < table.headers.count - 1 {
                result.append(NSAttributedString(string: "┴", attributes: [.font: style.bodyFont]))
            }
        }
        result.append(NSAttributedString(string: "┘\n\n", attributes: [.font: style.bodyFont]))

        return result
    }

    // MARK: - Inline Element Rendering

    private func renderInlineElements(_ elements: [InlineElement], baseFont: PlatformFont? = nil) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let font = baseFont ?? style.bodyFont

        for element in elements {
            result.append(renderInlineElement(element, baseFont: font))
        }

        return result
    }

    private func renderInlineElement(_ element: InlineElement, baseFont: PlatformFont) -> NSAttributedString {
        switch element {
        case .text(let string):
            let attributes: [NSAttributedString.Key: Any] = [
                .font: baseFont,
                .foregroundColor: style.textColor
            ]
            return NSAttributedString(string: string, attributes: attributes)

        case .strong(let children):
            let result = NSMutableAttributedString()
            for child in children {
                result.append(renderInlineElement(child, baseFont: baseFont))
            }
            // Make bold
            result.addAttribute(.font, value: baseFont.bold(), range: NSRange(location: 0, length: result.length))
            return result

        case .emphasis(let children):
            let result = NSMutableAttributedString()
            for child in children {
                result.append(renderInlineElement(child, baseFont: baseFont))
            }
            // Make italic
            result.addAttribute(.font, value: baseFont.italic(), range: NSRange(location: 0, length: result.length))
            return result

        case .strikethrough(let children):
            let result = NSMutableAttributedString()
            for child in children {
                result.append(renderInlineElement(child, baseFont: baseFont))
            }
            // Add strikethrough
            result.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: result.length))
            return result

        case .inlineCode(let code):
            // Use monospaced version of the base font to maintain size
            let monospacedFont = PlatformFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: monospacedFont,
                .foregroundColor: style.inlineCodeTextColor,
                .backgroundColor: style.inlineCodeBackgroundColor
            ]
            return NSAttributedString(string: code, attributes: attributes)

        case .link(let destination, let children):
            let result = NSMutableAttributedString()
            for child in children {
                result.append(renderInlineElement(child, baseFont: baseFont))
            }
            if let url = URL(string: destination) {
                result.addAttributes([
                    .link: url,
                    .foregroundColor: style.linkColor,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ], range: NSRange(location: 0, length: result.length))
            }
            return result

        case .softBreak:
            return NSAttributedString(string: " ")

        case .lineBreak:
            return NSAttributedString(string: "\n")
        }
    }
}

// MARK: - Font Extensions

extension PlatformFont {
    func bold() -> PlatformFont {
        #if canImport(UIKit)
        return UIFont.systemFont(ofSize: pointSize, weight: .bold)
        #elseif canImport(AppKit)
        return NSFont.boldSystemFont(ofSize: pointSize)
        #endif
    }

    func italic() -> PlatformFont {
        #if canImport(UIKit)
        return UIFont.italicSystemFont(ofSize: pointSize)
        #elseif canImport(AppKit)
        let fontDescriptor = self.fontDescriptor.withSymbolicTraits(.italic)
        return NSFont(descriptor: fontDescriptor, size: pointSize) ?? self
        #endif
    }
}
