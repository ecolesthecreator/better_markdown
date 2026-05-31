import Foundation
import Markdown

/// Parser that converts markdown strings to ParsedMarkdown using swift-markdown
public struct MarkdownParser {
    public init() {}

    /// Parse a markdown string into the intermediate representation
    public func parse(_ markdown: String) -> ParsedMarkdown {
        let document = Document(parsing: markdown)
        return parse(document: document)
    }

    /// Parse a swift-markdown Document into the intermediate representation
    public func parse(document: Document) -> ParsedMarkdown {
        let elements = document.children.compactMap { parseBlockElement($0) }
        return ParsedMarkdown(elements: elements)
    }

    // MARK: - Block Element Parsing

    private func parseBlockElement(_ markup: Markup) -> MarkdownElement? {
        switch markup {
        case let heading as Heading:
            return parseHeading(heading)
        case let paragraph as Paragraph:
            return parseParagraph(paragraph)
        case let codeBlock as CodeBlock:
            return parseCodeBlock(codeBlock)
        case let list as UnorderedList:
            return parseUnorderedList(list)
        case let list as OrderedList:
            return parseOrderedList(list)
        case let blockQuote as BlockQuote:
            return parseBlockQuote(blockQuote)
        case let table as Markdown.Table:
            return parseTable(table)
        case is ThematicBreak:
            return .thematicBreak
        default:
            // Handle unknown block elements by attempting to parse as paragraph
            return nil
        }
    }

    private func parseHeading(_ heading: Heading) -> MarkdownElement {
        let content = parseInlineElements(heading.children)
        return .heading(level: heading.level, content: content)
    }

    private func parseParagraph(_ paragraph: Paragraph) -> MarkdownElement {
        let content = parseInlineElements(paragraph.children)
        return .paragraph(content)
    }

    private func parseCodeBlock(_ codeBlock: CodeBlock) -> MarkdownElement {
        return .codeBlock(language: codeBlock.language, code: codeBlock.code)
    }

    private func parseUnorderedList(_ list: UnorderedList) -> MarkdownElement {
        let items = Array(list.listItems.map { parseListItem($0) })
        return .list(items: items, ordered: false)
    }

    private func parseOrderedList(_ list: OrderedList) -> MarkdownElement {
        let items = Array(list.listItems.map { parseListItem($0) })
        return .list(items: items, ordered: true)
    }

    private func parseListItem(_ item: Markdown.ListItem) -> ListItem {
        var content: [InlineElement] = []
        var nestedItems: [ListItem] = []

        for child in item.children {
            if let paragraph = child as? Paragraph {
                content.append(contentsOf: parseInlineElements(paragraph.children))
            } else if let nestedList = child as? UnorderedList {
                nestedItems = nestedList.listItems.map { parseListItem($0) }
            } else if let nestedList = child as? OrderedList {
                nestedItems = nestedList.listItems.map { parseListItem($0) }
            }
        }

        return ListItem(content: content, nestedItems: nestedItems)
    }

    private func parseBlockQuote(_ blockQuote: BlockQuote) -> MarkdownElement {
        let elements = blockQuote.children.compactMap { parseBlockElement($0) }
        return .blockQuote(elements)
    }

    private func parseTable(_ table: Markdown.Table) -> MarkdownElement {
        // Parse column alignments
        let alignments: [ColumnAlignment] = table.columnAlignments.map { alignment in
            switch alignment {
            case .left: return .left
            case .center: return .center
            case .right: return .right
            default: return .none
            }
        }

        // Parse header row
        let headers = Array(table.head.cells.map { cell in
            TableCell(content: parseInlineElements(cell.children))
        })

        // Parse body rows
        let rows = Array(table.body.rows.map { row in
            Array(row.cells.map { cell in
                TableCell(content: parseInlineElements(cell.children))
            })
        })

        return .table(Table(columnAlignments: alignments, headers: headers, rows: rows))
    }

    // MARK: - Inline Element Parsing

    private func parseInlineElements(_ children: MarkupChildren) -> [InlineElement] {
        children.flatMap { (markup: Markup) -> [InlineElement] in
            if let text = markup as? Text {
                return Self.autolinkText(text.string)
            }
            if let element = parseInlineElement(markup) {
                return [element]
            }
            return []
        }
    }

    private func parseInlineElement(_ markup: Markup) -> InlineElement? {
        switch markup {
        case let text as Text:
            // Handled by parseInlineElements via autolinkText, but kept for safety.
            return .text(text.string)
        case let strong as Strong:
            return .strong(parseInlineElements(strong.children))
        case let emphasis as Emphasis:
            return .emphasis(parseInlineElements(emphasis.children))
        case let strikethrough as Strikethrough:
            return .strikethrough(parseInlineElements(strikethrough.children))
        case let inlineCode as InlineCode:
            return .inlineCode(inlineCode.code)
        case let link as Link:
            return .link(destination: link.destination ?? "", children: parseInlineElements(link.children))
        case is SoftBreak:
            return .softBreak
        case is LineBreak:
            return .lineBreak
        default:
            // For unknown inline elements, try to extract text content
            if let text = markup.children.first as? Text {
                return .text(text.string)
            }
            return nil
        }
    }
    // MARK: - Autolinking

    /// Shared data detector for URLs. NSDataDetector is thread-safe for `matches(in:...)`.
    private static let urlDetector: NSDataDetector? = {
        try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    }()

    /// Allowlist of non-network schemes that `NSDataDetector` does **not** recognize but
    /// which we still want to render as tappable links. Add to this list to support more
    /// custom schemes. The generic `x-[a-z0-9.+-]+` form below also catches app-defined
    /// `x-callback-url`-style schemes without needing an explicit entry here.
    private static let customSchemes: [String] = [
        "file",
        "ssh", "sftp",
        "vscode", "vscode-insiders", "cursor", "zed", "fork", "sourcetree",
        "obsidian", "bear", "things", "notion",
        "slack", "zoommtg", "msteams", "tel", "sms", "facetime", "facetime-audio"
    ]

    /// Matches a bare custom-scheme URL such as `file:///Users/eric/foo.txt`,
    /// `ssh://host`, `vscode://file/...`, or any `x-*://...` app scheme. We stop at
    /// whitespace and at characters that almost certainly aren't part of the URL
    /// (`<>"'\``); trailing punctuation is trimmed in code below.
    private static let customSchemeRegex: NSRegularExpression? = {
        let alternation = (customSchemes + ["x-[a-z0-9.+-]+"]).joined(separator: "|")
        // (?<![A-Za-z0-9+.-]) prevents matching inside an existing scheme/identifier
        // (e.g. avoid grabbing `ssh` out of `gosshhost://`).
        let pattern = "(?<![A-Za-z0-9+.-])(?:\(alternation))://[^\\s<>\"'`\\\\]+"
        return try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
    }()

    /// Hard cap on the length of a single text run we'll autolink. Pathological inputs
    /// (e.g. a multi-KB base64 blob with no whitespace, or a tokenizer-mid-stream chunk)
    /// can otherwise push `NSDataDetector` and our regex into expensive territory. URLs
    /// users actually type are well under this bound; above it we fall back to plain text.
    private static let autolinkMaxLength = 16_384

    /// Split a plain text run into a sequence of `.text` and `.link` inline elements,
    /// auto-detecting bare URLs (e.g. `http://localhost:3000`, `www.example.com`,
    /// `foo@bar.com`, `file:///Users/eric/notes.md`, `vscode://file/...`) that
    /// swift-markdown does not turn into Link nodes on its own.
    static func autolinkText(_ string: String) -> [InlineElement] {
        guard !string.isEmpty else { return [.text(string)] }

        let nsString = string as NSString
        let fullRange = NSRange(location: 0, length: nsString.length)

        // Bail on huge runs — both detectors are linear-ish but on giant whitespace-free
        // blobs (logs, base64, encoded tokens) they can stall the main thread.
        guard nsString.length <= autolinkMaxLength else { return [.text(string)] }

        // Collect matches from both the network-URL detector and the custom-scheme regex.
        var rawMatches: [(range: NSRange, destination: String, matched: String)] = []

        if let detector = urlDetector {
            for m in detector.matches(in: string, options: [], range: fullRange) {
                let r = m.range
                guard r.location != NSNotFound else { continue }
                let matched = nsString.substring(with: r)
                let dest = m.url?.absoluteString ?? matched
                rawMatches.append((r, dest, matched))
            }
        }

        if let regex = customSchemeRegex {
            for m in regex.matches(in: string, options: [], range: fullRange) {
                var r = m.range
                guard r.location != NSNotFound, r.length > 0 else { continue }
                var matched = nsString.substring(with: r)
                let (trimmed, trimCount) = trimURLTail(matched)
                if trimCount > 0 {
                    matched = trimmed
                    // trimURLTail removes only ASCII punctuation/brackets, so each removed
                    // character is exactly one UTF-16 code unit — `trimCount` equals the
                    // NSRange length delta directly.
                    r = NSRange(location: r.location, length: r.length - trimCount)
                    if r.length == 0 { continue }
                }
                rawMatches.append((r, matched, matched))
            }
        }

        guard !rawMatches.isEmpty else { return [.text(string)] }

        // Sort by start, then drop any later match that overlaps an earlier one
        // (NSDataDetector wins ties because it was appended first).
        rawMatches.sort { $0.range.location < $1.range.location }
        var matches: [(range: NSRange, destination: String, matched: String)] = []
        var lastEnd = 0
        for m in rawMatches {
            if m.range.location < lastEnd { continue }
            matches.append(m)
            lastEnd = m.range.location + m.range.length
        }

        var elements: [InlineElement] = []
        var cursor = 0
        for m in matches {
            if m.range.location > cursor {
                let pre = nsString.substring(with: NSRange(location: cursor, length: m.range.location - cursor))
                if !pre.isEmpty { elements.append(.text(pre)) }
            }
            elements.append(.link(destination: m.destination, children: [.text(m.matched)]))
            cursor = m.range.location + m.range.length
        }

        if cursor < nsString.length {
            let tail = nsString.substring(with: NSRange(location: cursor, length: nsString.length - cursor))
            if !tail.isEmpty { elements.append(.text(tail)) }
        }

        return elements
    }

    /// Trim trailing punctuation and unbalanced closing brackets from a raw URL match.
    /// Returns the trimmed string and the number of UTF-16 code units removed (so the
    /// caller can fix up the `NSRange`). Operates on UTF-8 bytes because every character
    /// we look at (`. , ; : ! ? ( ) [ ] { }`) is single-byte ASCII; this keeps the routine
    /// O(n) total instead of O(n²) (the previous version re-scanned the whole URL for
    /// bracket balance on every pop, which became a pathological hotspot on long URLs).
    private static func trimURLTail(_ raw: String) -> (String, Int) {
        var bytes = Array(raw.utf8)

        // First, count opens/closes for each bracket flavor across the *full* string.
        // Each peel decision only needs to know whether the remaining inner string is
        // already balanced; we mutate these running counts as we trim.
        var openParen = 0, closeParen = 0
        var openBrack = 0, closeBrack = 0
        var openBrace = 0, closeBrace = 0
        for b in bytes {
            switch b {
            case 0x28: openParen += 1     // (
            case 0x29: closeParen += 1    // )
            case 0x5B: openBrack += 1     // [
            case 0x5D: closeBrack += 1    // ]
            case 0x7B: openBrace += 1     // {
            case 0x7D: closeBrace += 1    // }
            default: break
            }
        }

        var removed = 0
        loop: while let last = bytes.last {
            switch last {
            case 0x2E, 0x2C, 0x3B, 0x3A, 0x21, 0x3F: // . , ; : ! ?
                bytes.removeLast(); removed += 1
            case 0x29: // )
                // Strip only if the remaining inner text has at least as many ')' as '('.
                guard closeParen > openParen else { break loop }
                closeParen -= 1
                bytes.removeLast(); removed += 1
            case 0x5D: // ]
                guard closeBrack > openBrack else { break loop }
                closeBrack -= 1
                bytes.removeLast(); removed += 1
            case 0x7D: // }
                guard closeBrace > openBrace else { break loop }
                closeBrace -= 1
                bytes.removeLast(); removed += 1
            default:
                break loop
            }
        }

        return (String(decoding: bytes, as: UTF8.self), removed)
    }
}

// MARK: - Convenience Extensions

extension ParsedMarkdown {
    /// Parse markdown string directly into ParsedMarkdown
    public init(markdown: String) {
        let parser = MarkdownParser()
        self = parser.parse(markdown)
    }

    /// Parse swift-markdown Document directly into ParsedMarkdown
    public init(document: Document) {
        let parser = MarkdownParser()
        self = parser.parse(document: document)
    }
}
