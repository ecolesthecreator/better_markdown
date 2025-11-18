# Table Rendering Examples

BetterMarkdown now supports **tables** with proper alignment and styling!

## Basic Table

```markdown
| Feature | Status | Platform |
|---------|--------|----------|
| Headings | ✅ | All |
| Bold/Italic | ✅ | All |
| Tables | ✅ | All |
```

Renders as:

| Feature | Status | Platform |
|---------|--------|----------|
| Headings | ✅ | All |
| Bold/Italic | ✅ | All |
| Tables | ✅ | All |

## Aligned Columns

```markdown
| Left Aligned | Center Aligned | Right Aligned |
|:-------------|:--------------:|--------------:|
| Text         | Text           | Text          |
| More         | Content        | Here          |
```

Renders with proper alignment:

| Left Aligned | Center Aligned | Right Aligned |
|:-------------|:--------------:|--------------:|
| Text         | Text           | Text          |
| More         | Content        | Here          |

## Usage

### SwiftUI

```swift
import SwiftUI
import BetterMarkdown

struct TableExampleView: View {
    let markdown = """
    | Name | Age | City |
    |------|-----|------|
    | Alice | 30 | NYC |
    | Bob | 25 | SF |
    """

    var body: some View {
        MarkdownView(markdown: markdown)
            .padding()
    }
}
```

### NSAttributedString (UIKit/AppKit)

```swift
import BetterMarkdown

let markdown = """
| Column 1 | Column 2 |
|----------|----------|
| Value A  | Value B  |
"""

let attributed = AttributedStringRenderer.render(markdown: markdown)
textView.attributedText = attributed
```

The NSAttributedString renderer uses Unicode box-drawing characters for a clean text-based table:

```
┌───────┬───────┐
│ Col 1 │ Col 2 │
├───────┼───────┤
│ Val A │ Val B │
└───────┴───────┘
```

## Styling Options

Customize table appearance via `MarkdownStyle`:

```swift
let style = MarkdownStyle(
    tableHeaderBackgroundColor: .blue.opacity(0.2),
    tableRowBackgroundColor: .clear,
    tableAlternateRowBackgroundColor: .gray.opacity(0.1),
    tableBorderColor: .gray,
    tableCellPadding: EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
)

MarkdownView(markdown: tableMarkdown, style: style)
```

## Features

- ✅ **Column Alignment**: Left, center, right alignment support
- ✅ **Header Styling**: Bold headers with custom background
- ✅ **Alternating Rows**: Automatic zebra striping
- ✅ **Inline Formatting**: Bold, italic, code in cells
- ✅ **Border Styling**: Customizable borders and padding
- ✅ **NSAttributedString**: Text-based rendering with box characters
