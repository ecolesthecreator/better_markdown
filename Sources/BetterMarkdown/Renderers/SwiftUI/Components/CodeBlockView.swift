import SwiftUI

/// Renders a code block with optional syntax highlighting
struct CodeBlockView: View {
    let language: String?
    let code: String
    let style: MarkdownStyle

    // Cache the highlighted result to avoid re-highlighting on every render
    @State private var highlightedCode: AttributedString?
    @State private var cacheKey: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with language and copy button
            if let language = language, !language.isEmpty {
                HStack {
                    Text(language.uppercased())
                        .font(.caption)
                        .foregroundColor(style.textColor.opacity(0.6))

                    Spacer()

                    CopyButton(code: code, style: style)
                }
                .padding(.horizontal, style.codeBlockPadding.leading)
                .padding(.top, 8)
                .padding(.bottom, 4)
            } else {
                // No language, but still show copy button
                HStack {
                    Spacer()
                    CopyButton(code: code, style: style)
                }
                .padding(.horizontal, style.codeBlockPadding.leading)
                .padding(.top, 8)
                .padding(.bottom, 4)
            }

            ScrollView(.horizontal, showsIndicators: true) {
                codeContent
                    .padding(style.codeBlockPadding)
            }
            .frame(maxHeight: .infinity)
            .fixedSize(horizontal: false, vertical: true)
        }
        .background(style.codeBlockBackgroundColor)
        .cornerRadius(8)
        .padding(.bottom, style.paragraphSpacing)
        .onAppear {
            // Kick off highlighting when view appears (non-blocking)
            Task {
                await highlightCodeInBackground()
            }
        }
    }

    private var currentCacheKey: String {
        "\(language ?? "nil"):\(code.hashValue)"
    }

    private func highlightCodeInBackground() async {
        let key = currentCacheKey

        // Skip if already cached
        guard cacheKey != key else { return }

        // Perform highlighting on background thread
        let result: AttributedString? = await Task.detached {
            guard let highlighter = style.syntaxHighlighter,
                  let attributed = highlighter.highlight(code: code, language: language) else {
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
            Text(code)
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
            HStack(spacing: 4) {
                Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                    .font(.caption)
                Text(showCopied ? "Copied" : "Copy")
                    .font(.caption)
            }
            .foregroundColor(style.textColor.opacity(0.6))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.primary.opacity(0.05))
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
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

        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopied = false
            }
        }
    }
}

