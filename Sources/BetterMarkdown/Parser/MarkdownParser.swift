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
        children.compactMap { parseInlineElement($0) }
    }

    private func parseInlineElement(_ markup: Markup) -> InlineElement? {
        switch markup {
        case let text as Text:
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
