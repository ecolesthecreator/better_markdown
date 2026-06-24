import Foundation

/// Intermediate representation of parsed markdown that can be pre-parsed and cached
public struct ParsedMarkdown: Codable, Equatable, Sendable, Hashable {
    public let elements: [MarkdownElement]

    public init(elements: [MarkdownElement]) {
        self.elements = elements
    }
}

/// Block-level markdown elements
public enum MarkdownElement: Codable, Equatable, Sendable, Hashable {
    case heading(level: Int, content: [InlineElement])
    case paragraph([InlineElement])
    case codeBlock(language: String?, code: String)
    case list(items: [ListItem], ordered: Bool)
    case blockQuote([MarkdownElement])
    case table(Table)
    case thematicBreak
}

/// List item with potential nested content.
///
/// `content` holds the inline contents of the item's first paragraph (the typical
/// "label" of the bullet). `blocks` holds any additional block-level children that
/// appear inside the same list item — code blocks, block quotes, tables, secondary
/// paragraphs, etc. `nestedItems` is the list of sub-bullets when the child is
/// itself a list.
public struct ListItem: Codable, Equatable, Sendable, Hashable {
    public let content: [InlineElement]
    public let nestedItems: [ListItem]
    public let blocks: [MarkdownElement]

    public init(
        content: [InlineElement],
        nestedItems: [ListItem] = [],
        blocks: [MarkdownElement] = []
    ) {
        self.content = content
        self.nestedItems = nestedItems
        self.blocks = blocks
    }

    // Custom Codable so older cached `ParsedMarkdown` payloads (which were encoded
    // before the `blocks` field existed) still decode cleanly — missing key just
    // becomes an empty array.
    private enum CodingKeys: String, CodingKey {
        case content
        case nestedItems
        case blocks
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.content = try container.decode([InlineElement].self, forKey: .content)
        self.nestedItems = try container.decodeIfPresent([ListItem].self, forKey: .nestedItems) ?? []
        self.blocks = try container.decodeIfPresent([MarkdownElement].self, forKey: .blocks) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(content, forKey: .content)
        try container.encode(nestedItems, forKey: .nestedItems)
        try container.encode(blocks, forKey: .blocks)
    }
}

/// Table structure
public struct Table: Codable, Equatable, Sendable, Hashable {
    public let columnAlignments: [ColumnAlignment]
    public let headers: [TableCell]
    public let rows: [[TableCell]]

    public init(columnAlignments: [ColumnAlignment], headers: [TableCell], rows: [[TableCell]]) {
        self.columnAlignments = columnAlignments
        self.headers = headers
        self.rows = rows
    }
}

/// Table column alignment
public enum ColumnAlignment: String, Codable, Equatable, Sendable, Hashable {
    case left
    case center
    case right
    case none
}

/// Table cell content
public struct TableCell: Codable, Equatable, Sendable, Hashable {
    public let content: [InlineElement]

    public init(content: [InlineElement]) {
        self.content = content
    }
}

/// Inline markdown elements
public indirect enum InlineElement: Codable, Equatable, Sendable, Hashable {
    case text(String)
    case strong([InlineElement])  // Bold
    case emphasis([InlineElement]) // Italic
    case strikethrough([InlineElement])
    case inlineCode(String)
    case link(destination: String, children: [InlineElement])
    case softBreak
    case lineBreak
}

// MARK: - Convenience Extensions

extension ParsedMarkdown {
    /// Create an empty parsed markdown
    public static var empty: ParsedMarkdown {
        ParsedMarkdown(elements: [])
    }

    // MARK: - Codable Caching Helpers

    /// Encode to JSON Data for caching
    public func encode() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    /// Decode from JSON Data
    public static func decode(from data: Data) throws -> ParsedMarkdown {
        let decoder = JSONDecoder()
        return try decoder.decode(ParsedMarkdown.self, from: data)
    }

    /// Save to file
    public func save(to url: URL) throws {
        let data = try encode()
        try data.write(to: url)
    }

    /// Load from file
    public static func load(from url: URL) throws -> ParsedMarkdown {
        let data = try Data(contentsOf: url)
        return try decode(from: data)
    }
}

extension InlineElement {
    /// Extract plain text from inline elements
    public var plainText: String {
        switch self {
        case .text(let string):
            return string
        case .strong(let elements), .emphasis(let elements), .strikethrough(let elements):
            return elements.map { $0.plainText }.joined()
        case .inlineCode(let code):
            return code
        case .link(_, let children):
            return children.map { $0.plainText }.joined()
        case .softBreak:
            return " "
        case .lineBreak:
            return "\n"
        }
    }
}

extension Array where Element == InlineElement {
    /// Extract plain text from an array of inline elements
    public var plainText: String {
        map { $0.plainText }.joined()
    }
}
