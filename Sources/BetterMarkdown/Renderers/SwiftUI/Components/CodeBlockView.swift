import SwiftUI

#if os(macOS)
import AppKit
#endif

// MARK: - macOS Horizontal Scroll View

#if os(macOS)
/// A horizontal-only scroll view that passes vertical scroll events to the parent scroll view
/// This fixes the issue where hovering over a code block prevents scrolling the chat
struct HorizontalScrollView<Content: View>: NSViewRepresentable {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = VerticalPassthroughScrollView()
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false

        // Create the hosting view for SwiftUI content
        let hostingView = NSHostingView(rootView: content)
        hostingView.translatesAutoresizingMaskIntoConstraints = false

        // Use a flipped clip view for proper coordinate system
        let clipView = NSClipView()
        clipView.drawsBackground = false
        clipView.documentView = hostingView

        scrollView.contentView = clipView

        // Set up constraints so content determines height
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: clipView.topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: clipView.leadingAnchor),
            hostingView.bottomAnchor.constraint(equalTo: clipView.bottomAnchor)
        ])

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        if let hostingView = scrollView.documentView as? NSHostingView<Content> {
            hostingView.rootView = content
        }
    }
}

/// Custom NSScrollView that passes vertical scroll events to its parent
private class VerticalPassthroughScrollView: NSScrollView {
    override func scrollWheel(with event: NSEvent) {
        // If scrolling is primarily vertical, pass to next responder (parent scroll view)
        if abs(event.scrollingDeltaY) > abs(event.scrollingDeltaX) {
            nextResponder?.scrollWheel(with: event)
        } else {
            // Horizontal scroll - handle normally
            super.scrollWheel(with: event)
        }
    }
}
#endif

/// Renders a code block with optional syntax highlighting
struct CodeBlockView: View {
    let language: String?
    let code: String
    let style: MarkdownStyle

    @Environment(\.colorScheme) private var colorScheme

    // Cache the highlighted result to avoid re-highlighting on every render
    @State private var highlightedCode: AttributedString?
    @State private var cacheKey: String = ""

    /// `CodeBlock.code` from swift-markdown is guaranteed to end in a newline,
    /// which renders as an empty final line — a whole line of dead space
    /// between the last line of code and the bottom of the container. Nothing
    /// downstream wants it, including the pasteboard.
    private var displayCode: String {
        var trimmed = Substring(code)
        while let last = trimmed.last, last.isNewline {
            trimmed = trimmed.dropLast()
        }
        return String(trimmed)
    }

    /// An unlabeled fence still gets a label, so the header never collapses to
    /// a lone copy button floating at the trailing edge.
    private var languageDisplayName: String {
        guard let language, !language.trimmingCharacters(in: .whitespaces).isEmpty else {
            return "text"
        }
        return language.trimmingCharacters(in: .whitespaces).lowercased()
    }

    /// The header fill and divider are tints applied *over* the body fill
    /// rather than absolute grays, so they track whatever
    /// `codeBlockBackgroundColor` the host app injects instead of needing to
    /// be re-tuned every time that changes.
    private var headerTint: Color {
        colorScheme == .dark ? Color.black.opacity(0.30) : Color.black.opacity(0.045)
    }

    private var dividerColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.10) : Color.black.opacity(0.10)
    }

    private var isHairlineBorderVisible: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Full-bleed header strip: lowercase monospaced language label at
            // the leading edge, copy button at the trailing edge, hairline
            // divider marking the seam with the code below.
            //
            // The strip runs edge to edge on purpose. Inset it and the divider
            // reads as a floating rule instead of a seam.
            HStack {
                Text(languageDisplayName)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(style.textColor.opacity(0.6))

                Spacer()

                CopyButton(code: displayCode, style: style)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(headerTint)

            Rectangle()
                .fill(dividerColor)
                .frame(height: 1)

            #if os(macOS)
            // Use a horizontal-only scroll view that passes vertical scroll events to parent
            HorizontalScrollView {
                codeContent
                    .padding(style.codeBlockPadding)
            }
            .frame(maxHeight: .infinity)
            .fixedSize(horizontal: false, vertical: true)
            #else
            ScrollView(.horizontal, showsIndicators: true) {
                codeContent
                    .padding(style.codeBlockPadding)
            }
            .frame(maxHeight: .infinity)
            .fixedSize(horizontal: false, vertical: true)
            #endif
        }
        .background(style.codeBlockBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            // A hairline edge on macOS only. The Mac's panes are a mid gray in
            // dark mode and an off-white in light, so the slab's own fill has
            // much less contrast to separate against than it does against
            // iOS's near-black / white page.
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(
                    colorScheme == .dark
                        ? Color(white: 1, opacity: 0.08)
                        : Color(white: 0, opacity: 0.08),
                    lineWidth: isHairlineBorderVisible ? 1 : 0
                )
        )
        .padding(.bottom, style.paragraphSpacing)
        .onAppear {
            // Kick off highlighting when view appears (non-blocking)
            Task {
                await highlightCodeInBackground()
            }
        }
    }

    private var currentCacheKey: String {
        "\(language ?? "nil"):\(displayCode.hashValue)"
    }

    private func highlightCodeInBackground() async {
        let key = currentCacheKey

        // Skip if already cached
        guard cacheKey != key else { return }

        // Read everything the detached task needs up front. Reaching into
        // `self` from inside `Task.detached` touches main-actor-isolated
        // state off the main actor, which is an error under Swift 6.
        let highlighter = style.syntaxHighlighter
        let source = displayCode
        let languageHint = language

        // Perform highlighting on background thread
        let result: AttributedString? = await Task.detached {
            guard let highlighter,
                  let attributed = highlighter.highlight(code: source, language: languageHint) else {
                return nil
            }
            return AttributedString(attributed)
        }.value

        // Update cache on main thread
        await MainActor.run {
            self.highlightedCode = result
            self.cacheKey = key
        }
    }

    @ViewBuilder
    private var codeContent: some View {
        if let highlighted = highlightedCode {
            // Use cached highlighted code
            Text(highlighted)
        } else {
            // Fallback to plain text while highlighting
            Text(displayCode)
                .font(style.codeFont)
                .foregroundColor(style.codeBlockTextColor)
        }
    }
}

/// Slim copy button for code blocks
struct CopyButton: View {
    let code: String
    let style: MarkdownStyle

    @State private var showCopied = false

    var body: some View {
        Button(action: copyToClipboard) {
            Image(systemName: showCopied ? "checkmark" : "square.on.square")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(showCopied ? .green : style.textColor.opacity(0.6))
                .animation(.easeInOut(duration: 0.15), value: showCopied)
                // Keep the tap target from shifting as the glyph swaps — the
                // checkmark is narrower than the two-squares icon.
                .frame(width: 18, height: 18)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(showCopied ? "Copied" : "Copy code")
    }

    private func copyToClipboard() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
        #elseif os(iOS)
        UIPasteboard.general.string = code
        #endif

        // Show "Copied" feedback
        withAnimation {
            showCopied = true
        }

        // Reset after 1.5s — the same dwell every other copy affordance in the
        // app uses.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showCopied = false
            }
        }
    }
}

