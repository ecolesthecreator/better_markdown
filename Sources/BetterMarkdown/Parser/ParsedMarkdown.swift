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

/// List item with potential nested content
public struct ListItem: Codable, Equatable, Sendable, Hashable {
    public let content: [InlineElement]
    public let nestedItems: [ListItem]

    public init(content: [InlineElement], nestedItems: [ListItem] = []) {
        self.content = content
        self.nestedItems = nestedItems
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
        case .softBreak, .lineBreak:
            return " "
        }
    }
}

extension Array where Element == InlineElement {
    /// Extract plain text from an array of inline elements
    public var plainText: String {
        map { $0.plainText }.joined()
    }
}
