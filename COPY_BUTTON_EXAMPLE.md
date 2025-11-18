# Code Block Copy Button

BetterMarkdown now includes a built-in **Copy** button in all code blocks!

## Features

- ✅ **Slim UI**: Minimal, non-intrusive button in the trailing edge of the code block header
- ✅ **Smart Placement**:
  - Shows next to language label when present
  - Always visible, even for code blocks without a language
- ✅ **Visual Feedback**: Button changes to "Copied" with checkmark icon for 2 seconds
- ✅ **Cross-Platform**: Works on both macOS and iOS
- ✅ **Clean Copy**: Copies only the code content (no backticks or language identifier)

## Example

````markdown
```swift
func greet(name: String) {
    print("Hello, \(name)!")
}
```
````

When rendered, this code block will have:
- "SWIFT" label on the left
- "Copy" button on the right
- Clicking "Copy" will copy just the function code to clipboard

## Code Block Without Language

````markdown
```
Some plain text
Multiple lines
```
````

Even without a language label, the Copy button is still available in the top-right corner.

## Implementation Details

### Button States
- **Default**: Shows "Copy" with document icon
- **After Click**: Shows "Copied" with checkmark icon
- **Auto-Reset**: Returns to default state after 2 seconds

### Styling
- Uses caption font size for minimal visual weight
- Matches the code block's text color at 60% opacity
- Subtle background for better visibility
- Rounded corners to match code block style

### Platform Support
- **macOS**: Uses `NSPasteboard`
- **iOS**: Uses `UIPasteboard`
- **tvOS/watchOS**: Copy functionality available where pasteboard is supported

## Usage

No special configuration needed - the copy button is automatically included in all code blocks rendered with `MarkdownView`:

```swift
import SwiftUI
import BetterMarkdown

struct ContentView: View {
    let markdown = """
    ```python
    def hello():
        print("Hello, World!")
    ```
    """

    var body: some View {
        MarkdownView(markdown: markdown)
            .padding()
    }
}
```

The copy button is part of the SwiftUI rendering only (not available in NSAttributedString renderer).
