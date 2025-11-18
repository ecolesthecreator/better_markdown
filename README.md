# BetterMarkdown

A powerful Swift package for rendering Markdown with both **SwiftUI** and **NSAttributedString** support. Built on top of [swift-markdown](https://github.com/swiftlang/swift-markdown) with integrated syntax highlighting via [Highlightr](https://github.com/raspu/Highlightr).

## Features

✨ **Dual Rendering**
- SwiftUI components (modern, declarative)
- NSAttributedString (UIKit/AppKit compatibility)

🎨 **Fully Customizable**
- **Scalable fonts** with platform-specific defaults
- Font colors and sizes for all elements
- Background colors for code blocks and quotes
- Syntax highlighting with Highlightr
- Custom spacing and padding
- Accessibility-friendly font scaling

🚀 **Performance Optimized**
- Pre-parsing support for caching
- Parse once, render many times
- Efficient intermediate representation
- `Codable` support for disk/network caching
- `Equatable` and `Sendable` conformance

📝 **Comprehensive Markdown Support**
- Headings (H1-H4)
- Text formatting (Bold, Italic, Strikethrough)
- Inline code and code blocks
- Unordered and ordered lists (with nesting)
- Block quotes
- Horizontal rules

## Installation

### Swift Package Manager

Add BetterMarkdown to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/YOUR_USERNAME/BetterMarkdown.git", from: "1.0.0")
]
```

Or add it in Xcode: File > Add Package Dependencies...

## Usage

### SwiftUI Rendering

```swift
import SwiftUI
import BetterMarkdown

struct ContentView: View {
    let markdown = """
    # Hello, World!

    This is **bold** and this is *italic*.

    ```swift
    let code = "Hello, Swift!"
    print(code)
    ```

    - Item 1
    - Item 2
    - Item 3
    """

    var body: some View {
        ScrollView {
            MarkdownView(markdown: markdown)
                .padding()
        }
    }
}
```

#### Custom Styling

```swift
// Simple: just change colors
let customStyle = MarkdownStyle(
    textColor: .primary,
    codeBlockBackgroundColor: Color.blue.opacity(0.1),
    inlineCodeTextColor: .orange,
    syntaxHighlighter: HighlightrAdapter(theme: "monokai")
)

MarkdownView(markdown: markdown, style: customStyle)
```

#### Scalable Fonts (New!)

All fonts are **relative to a base size** that's platform-appropriate by default:

```swift
// Use default platform size (17pt iOS, 13pt macOS, 29pt tvOS, 16pt watchOS)
let style = MarkdownStyle()

// Custom base size (all fonts scale proportionally)
let style = MarkdownStyle(baseFontSize: 20)

// Scale all fonts by a factor (great for accessibility!)
let style = MarkdownStyle(fontScale: 1.5)

// Combine both
let style = MarkdownStyle(baseFontSize: 18, fontScale: 1.2)

// Dynamic scaling
let largerStyle = style.scaled(by: 1.3)
```

**Font Scaling Multipliers:**
- H1: 2.0× base (26pt on macOS, 34pt on iOS)
- H2: 1.69× base (22pt on macOS, 29pt on iOS)
- H3: 1.54× base (20pt on macOS, 26pt on iOS)
- H4: 1.38× base (18pt on macOS, 23pt on iOS)
- Body: 1.0× base
- Code: 0.94× base

See [FONT_SCALING_EXAMPLE.md](FONT_SCALING_EXAMPLE.md) for detailed examples including accessibility support!

### NSAttributedString Rendering

```swift
import BetterMarkdown

// Basic usage
let attributed = AttributedStringRenderer.render(
    markdown: "# Hello\nThis is **bold**"
)
label.attributedText = attributed

// With custom style
let style = AttributedStringStyle(
    h1Font: .systemFont(ofSize: 32, weight: .bold),
    textColor: .label,
    codeBlockBackgroundColor: .systemGray6,
    syntaxHighlighter: HighlightrAdapter(theme: "xcode")
)

let attributed = AttributedStringRenderer.render(
    markdown: markdown,
    style: style
)
```

### Pre-Parsing for Performance

For frequently rendered markdown (e.g., in table cells), parse once and reuse:

```swift
// Parse once
let parsed = ParsedMarkdown(markdown: complexMarkdown)

// Render many times (SwiftUI)
ForEach(items) { item in
    MarkdownView(parsed: parsed, style: .default)
}

// Or with NSAttributedString
let renderer = AttributedStringRenderer(style: .default)
let attributed = renderer.render(parsed)
```

### Caching Parsed Markdown

`ParsedMarkdown` conforms to `Codable`, so you can cache it to disk or network:

```swift
// Parse markdown
let parsed = ParsedMarkdown(markdown: complexMarkdown)

// Save to file
try parsed.save(to: cacheURL)

// Load from file later (skip parsing!)
let cached = try ParsedMarkdown.load(from: cacheURL)
MarkdownView(parsed: cached)

// Or encode/decode manually
let data = try parsed.encode()
UserDefaults.standard.set(data, forKey: "cachedMarkdown")

// Later...
if let data = UserDefaults.standard.data(forKey: "cachedMarkdown") {
    let parsed = try ParsedMarkdown.decode(from: data)
    MarkdownView(parsed: parsed)
}
```

**Benefits:**
- ✅ Skip expensive parsing on app launch
- ✅ Cache markdown from network responses
- ✅ `Codable` + `Equatable` + `Sendable` support

### Syntax Highlighting

#### Using Highlightr

```swift
// Create highlighter with theme
let highlighter = HighlightrAdapter(theme: "monokai")

// Apply to SwiftUI
let style = MarkdownStyle(syntaxHighlighter: highlighter)
MarkdownView(markdown: markdown, style: style)

// Or NSAttributedString
let attrStyle = AttributedStringStyle(syntaxHighlighter: highlighter)
let attributed = AttributedStringRenderer.render(markdown: markdown, style: attrStyle)

// Available themes
print(highlighter?.availableThemes)
// ["xcode", "monokai", "github", "solarized-dark", ...]
```

#### Custom Highlighter

Implement the `SyntaxHighlighter` protocol:

```swift
class MyHighlighter: SyntaxHighlighter {
    func highlight(code: String, language: String?) -> NSAttributedString? {
        // Your custom highlighting logic
        return NSAttributedString(string: code, attributes: [...])
    }
}

let style = MarkdownStyle(syntaxHighlighter: MyHighlighter())
```

## Customization Options

### MarkdownStyle (SwiftUI)

```swift
MarkdownStyle(
    // Typography
    h1Font: Font,
    h2Font: Font,
    h3Font: Font,
    h4Font: Font,
    bodyFont: Font,
    codeFont: Font,

    // Colors
    textColor: Color,
    backgroundColor: Color,
    codeBlockBackgroundColor: Color,
    codeBlockTextColor: Color,
    inlineCodeBackgroundColor: Color,
    inlineCodeTextColor: Color,
    blockQuoteBackgroundColor: Color,
    blockQuoteBorderColor: Color,

    // Spacing
    headingSpacing: CGFloat,
    paragraphSpacing: CGFloat,
    listItemSpacing: CGFloat,
    codeBlockPadding: EdgeInsets,
    inlineCodePadding: EdgeInsets,
    blockQuotePadding: EdgeInsets,

    // Highlighting
    syntaxHighlighter: SyntaxHighlighter?
)
```

### AttributedStringStyle (UIKit/AppKit)

```swift
AttributedStringStyle(
    // Typography
    h1Font: UIFont/NSFont,
    h2Font: UIFont/NSFont,
    // ... similar to SwiftUI

    // Colors use UIColor/NSColor
    textColor: UIColor/NSColor,
    codeBlockBackgroundColor: UIColor/NSColor,
    // ...

    syntaxHighlighter: SyntaxHighlighter?
)
```

## Supported Markdown Elements

| Element | Syntax | Support |
|---------|--------|---------|
| Heading 1-4 | `# H1` ... `#### H4` | ✅ |
| Bold | `**text**` | ✅ |
| Italic | `*text*` | ✅ |
| Strikethrough | `~~text~~` | ✅ |
| Inline Code | `` `code` `` | ✅ |
| Code Block | ` ```lang ` | ✅ (with highlighting) |
| Unordered List | `- item` | ✅ (with nesting) |
| Ordered List | `1. item` | ✅ (with nesting) |
| Block Quote | `> quote` | ✅ |
| Horizontal Rule | `---` | ✅ |

## Examples

### Complete Example

```swift
import SwiftUI
import BetterMarkdown

struct MarkdownDemoView: View {
    let markdown = """
    # BetterMarkdown Demo

    ## Features

    This package supports **bold**, *italic*, and ~~strikethrough~~ text.

    ### Code

    Inline code: `let x = 10`

    Code blocks with syntax highlighting:

    ```swift
    struct ContentView: View {
        var body: some View {
            Text("Hello, World!")
        }
    }
    ```

    ### Lists

    - Unordered lists
    - With multiple items
      - And nested items
      - Like this

    ### Quotes

    > This is a block quote.
    > It can span multiple lines.

    ---

    That's all!
    """

    var body: some View {
        ScrollView {
            MarkdownView(
                markdown: markdown,
                style: MarkdownStyle(
                    textColor: .primary,
                    codeBlockBackgroundColor: Color.gray.opacity(0.15),
                    syntaxHighlighter: HighlightrAdapter(theme: "xcode")
                )
            )
            .padding()
        }
    }
}
```

## Requirements

- iOS 15.0+ / macOS 12.0+ / watchOS 8.0+ / tvOS 15.0+
- Swift 5.9+
- Xcode 15.0+

## Dependencies

- [swift-markdown](https://github.com/swiftlang/swift-markdown) - Markdown parsing
- [Highlightr](https://github.com/raspu/Highlightr) - Syntax highlighting

## License

MIT License - feel free to use in your projects!

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

Created with ❤️ using Claude Code
