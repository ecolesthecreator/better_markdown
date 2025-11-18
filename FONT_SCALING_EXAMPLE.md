# Font Scaling Examples

BetterMarkdown now supports **scalable, platform-aware fonts** with a base size system. All heading and body fonts are **relative** to a configurable base size.

## Platform-Specific Defaults

BetterMarkdown automatically selects the appropriate base font size for each platform:

| Platform | Default Base Size |
|----------|-------------------|
| iOS      | 17pt             |
| macOS    | 13pt             |
| tvOS     | 29pt             |
| watchOS  | 16pt             |

All other font sizes are **relative multipliers** of this base:
- **H1**: 2.15× base (~28pt on macOS, ~37pt on iOS)
- **H2**: 1.85× base (~24pt on macOS, ~31pt on iOS)
- **H3**: 1.54× base (~20pt on macOS, ~26pt on iOS)
- **H4**: 1.38× base (~18pt on macOS, ~23pt on iOS)
- **Body**: 1.0× base
- **Code**: 0.94× base (slightly smaller)

## Basic Usage

### Default (Platform-Specific)

```swift
import BetterMarkdown

// Uses platform default base size
// iOS: 17pt, macOS: 13pt, tvOS: 29pt, watchOS: 16pt
let style = MarkdownStyle()
MarkdownView(markdown: "# Hello", style: style)
```

### Custom Base Size

```swift
// Use 20pt as base size on all platforms
let style = MarkdownStyle(baseFontSize: 20)
// Results:
// - H1: 40pt (20 * 2.0)
// - H2: 34pt (20 * 1.69)
// - H3: 31pt (20 * 1.54)
// - H4: 28pt (20 * 1.38)
// - Body: 20pt
// - Code: 18.8pt (20 * 0.94)

MarkdownView(markdown: markdown, style: style)
```

### Font Scale (Accessibility)

```swift
// Keep platform default, but scale everything up by 1.25x
let style = MarkdownStyle(fontScale: 1.25)
// On iOS (17pt base):
// - H1: 42.5pt (17 * 2.0 * 1.25)
// - H2: 35.9pt (17 * 1.69 * 1.25)
// - Body: 21.25pt (17 * 1.25)

MarkdownView(markdown: markdown, style: style)
```

### Combine Base Size + Scale

```swift
// Custom base size AND scale
let style = MarkdownStyle(
    baseFontSize: 16,
    fontScale: 1.5
)
// Results:
// - H1: 48pt (16 * 2.0 * 1.5)
// - H2: 40.6pt (16 * 1.69 * 1.5)
// - Body: 24pt (16 * 1.5)
```

### Dynamic Scaling Method

```swift
let baseStyle = MarkdownStyle(baseFontSize: 18)

// User increases font size
let largerStyle = baseStyle.scaled(by: 1.2)

// User decreases font size
let smallerStyle = baseStyle.scaled(by: 0.8)
```

## SwiftUI Examples

### Accessibility Settings

```swift
import SwiftUI
import BetterMarkdown

struct ArticleView: View {
    @Environment(\.sizeCategory) var sizeCategory
    let markdown: String

    var style: MarkdownStyle {
        let scale = scaleFactor(for: sizeCategory)
        return MarkdownStyle(fontScale: scale)
    }

    var body: some View {
        ScrollView {
            MarkdownView(markdown: markdown, style: style)
                .padding()
        }
    }

    func scaleFactor(for category: ContentSizeCategory) -> CGFloat {
        switch category {
        case .extraSmall: return 0.8
        case .small: return 0.9
        case .medium: return 1.0
        case .large: return 1.0
        case .extraLarge: return 1.1
        case .extraExtraLarge: return 1.2
        case .extraExtraExtraLarge: return 1.3
        case .accessibilityMedium: return 1.4
        case .accessibilityLarge: return 1.6
        case .accessibilityExtraLarge: return 1.8
        case .accessibilityExtraExtraLarge: return 2.0
        case .accessibilityExtraExtraExtraLarge: return 2.2
        @unknown default: return 1.0
        }
    }
}
```

### User Preference Slider

```swift
struct MarkdownReaderView: View {
    @State private var fontScale: Double = 1.0
    let markdown: String

    var body: some View {
        VStack {
            Slider(value: $fontScale, in: 0.5...2.0, step: 0.1) {
                Text("Font Size")
            }
            .padding()

            ScrollView {
                MarkdownView(
                    markdown: markdown,
                    style: MarkdownStyle(fontScale: fontScale)
                )
                .padding()
            }
        }
    }
}
```

### Different Sizes for Different Contexts

```swift
struct MultiContextView: View {
    let markdown: String

    var body: some View {
        VStack {
            // Large for main content
            MarkdownView(
                markdown: markdown,
                style: MarkdownStyle(baseFontSize: 18)
            )
            .frame(height: 400)

            Divider()

            // Small for preview
            MarkdownView(
                markdown: markdown,
                style: MarkdownStyle(baseFontSize: 12)
            )
            .frame(height: 200)
        }
    }
}
```

## NSAttributedString Examples

### UIKit with Scalable Fonts

```swift
import UIKit
import BetterMarkdown

class ArticleViewController: UIViewController {
    let textView = UITextView()
    var currentScale: CGFloat = 1.0

    func updateMarkdown(_ markdown: String, scale: CGFloat) {
        let style = AttributedStringStyle(fontScale: scale)
        let attributed = AttributedStringRenderer.render(
            markdown: markdown,
            style: style
        )
        textView.attributedText = attributed
    }

    @objc func increaseFontSize() {
        currentScale *= 1.1
        updateMarkdown(currentMarkdown, scale: currentScale)
    }

    @objc func decreaseFontSize() {
        currentScale *= 0.9
        updateMarkdown(currentMarkdown, scale: currentScale)
    }
}
```

### macOS with User Preferences

```swift
import AppKit
import BetterMarkdown

class DocumentViewController: NSViewController {
    let textView = NSTextView()

    func renderMarkdown(_ markdown: String) {
        // Get user's preferred font size from UserDefaults
        let userBaseFontSize = UserDefaults.standard.double(forKey: "baseFontSize")
        let baseFontSize = userBaseFontSize > 0 ? CGFloat(userBaseFontSize) : AttributedStringStyle.defaultBaseFontSize

        let style = AttributedStringStyle(baseFontSize: baseFontSize)
        let attributed = AttributedStringRenderer.render(
            markdown: markdown,
            style: style
        )
        textView.textStorage?.setAttributedString(attributed)
    }
}
```

## Override Individual Fonts

You can still override individual fonts while keeping others scaled:

```swift
// Custom H1, but other headings scale normally
let style = MarkdownStyle(
    baseFontSize: 17,
    h1Font: .custom("Georgia", size: 40).weight(.heavy), // Custom
    // h2, h3, h4 will use scaled defaults
    fontScale: 1.2
)
```

## Benefits

### ✅ **Platform Consistency**
Fonts automatically match platform conventions (17pt on iOS, 13pt on macOS, etc.)

### ✅ **Accessibility**
Easy to scale all fonts proportionally for users with vision needs

### ✅ **User Preferences**
Let users choose their preferred reading size

### ✅ **Responsive Design**
Different contexts can use different scales (main content vs. preview)

### ✅ **Relative Sizing**
All headings maintain proper hierarchy regardless of base size

### ✅ **Backward Compatible**
Still supports direct font overrides for maximum flexibility

## Complete Example

```swift
import SwiftUI
import BetterMarkdown

struct ConfigurableMarkdownView: View {
    let markdown = """
    # Scalable Markdown

    This is body text that scales with the base font size.

    ## Features

    - **Platform-aware** defaults
    - *Scalable* fonts
    - `Code blocks` that scale too

    ### Code Example

    \```swift
    let style = MarkdownStyle(fontScale: 1.5)
    \```
    """

    @AppStorage("fontScale") private var fontScale: Double = 1.0
    @AppStorage("baseFontSize") private var baseFontSize: Double = 0

    var style: MarkdownStyle {
        let base = baseFontSize > 0 ? CGFloat(baseFontSize) : nil
        return MarkdownStyle(
            baseFontSize: base,
            fontScale: fontScale
        )
    }

    var body: some View {
        VStack {
            // Controls
            HStack {
                Text("Base Size:")
                Slider(
                    value: $baseFontSize,
                    in: 0...30,
                    step: 1
                )
                Text(baseFontSize > 0 ? "\(Int(baseFontSize))pt" : "Auto")
            }
            .padding()

            HStack {
                Text("Scale:")
                Slider(
                    value: $fontScale,
                    in: 0.5...2.0,
                    step: 0.1
                )
                Text(String(format: "%.1f×", fontScale))
            }
            .padding()

            Divider()

            // Markdown content
            ScrollView {
                MarkdownView(markdown: markdown, style: style)
                    .padding()
            }
        }
    }
}
```

## Migration Guide

### Before (Fixed Sizes)

```swift
// Old way: hardcoded sizes
let style = MarkdownStyle(
    h1Font: .system(size: 32, weight: .bold),
    h2Font: .system(size: 28, weight: .bold),
    bodyFont: .system(size: 17)
)
```

### After (Scalable)

```swift
// New way: scalable base
let style = MarkdownStyle(
    baseFontSize: 17,  // All fonts scale from this
    fontScale: 1.0     // Can easily scale up/down
)

// Or just use defaults
let style = MarkdownStyle() // Platform-appropriate!
```

The new system is **fully backward compatible** - you can still override individual fonts, but now you have the *option* to use the scalable system!
