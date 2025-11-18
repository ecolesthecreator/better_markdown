# BetterMarkdown Package Structure

## Overview

**BetterMarkdown** is a Swift package for rendering Markdown using both SwiftUI and NSAttributedString, with full caching support via `Codable`.

## Directory Structure

```
better_markdown/                        # Root directory
├── Package.swift                       # Package manifest
├── README.md                           # Main documentation
├── CACHING_EXAMPLE.md                  # Caching examples
├── Sources/
│   └── BetterMarkdown/                 # Main module
│       ├── BetterMarkdown.swift        # Module entry point
│       ├── Parser/
│       │   ├── ParsedMarkdown.swift    # Codable intermediate representation
│       │   └── MarkdownParser.swift    # swift-markdown integration
│       ├── Highlighting/
│       │   ├── SyntaxHighlighter.swift # Protocol for syntax highlighters
│       │   └── HighlightrAdapter.swift # Highlightr implementation
│       └── Renderers/
│           ├── SwiftUI/
│           │   ├── MarkdownView.swift  # Main SwiftUI view
│           │   ├── MarkdownStyle.swift # SwiftUI style configuration
│           │   └── Components/
│           │       ├── HeadingView.swift
│           │       ├── CodeBlockView.swift
│           │       ├── InlineTextView.swift
│           │       ├── ListItemView.swift
│           │       ├── BlockQuoteView.swift
│           │       └── MarkdownElementView.swift
│           └── AttributedString/
│               ├── AttributedStringRenderer.swift  # NSAttributedString renderer
│               └── AttributedStringStyle.swift     # NSAttributedString style config
└── Tests/
    └── BetterMarkdownTests/
        └── MarkdownRendererTests.swift
```

## Module Name

- **Package Name**: BetterMarkdown
- **Module Name**: BetterMarkdown
- **Import Statement**: `import BetterMarkdown`

## Usage

### SwiftUI
```swift
import BetterMarkdown

MarkdownView(markdown: "# Hello")
```

### NSAttributedString
```swift
import BetterMarkdown

let attributed = AttributedStringRenderer.render(markdown: "# Hello")
```

### Caching
```swift
import BetterMarkdown

// Parse and cache
let parsed = ParsedMarkdown(markdown: markdown)
try parsed.save(to: fileURL)

// Load from cache
let cached = try ParsedMarkdown.load(from: fileURL)
```

## Key Features

✅ **Unnested Structure** - Package files at root of repository
✅ **Single Module** - All code under `BetterMarkdown` module
✅ **Clean Naming** - Consistent "BetterMarkdown" throughout
✅ **Codable Support** - Full caching capabilities
✅ **Dual Renderers** - SwiftUI + NSAttributedString
✅ **Syntax Highlighting** - Highlightr integration
