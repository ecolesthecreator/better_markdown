# Caching Examples

## Example 1: Simple File-Based Cache

```swift
import BetterMarkdown
import Foundation

class MarkdownCache {
    let cacheDirectory: URL

    init() {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = paths[0].appendingPathComponent("MarkdownCache")
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func cacheURL(for key: String) -> URL {
        return cacheDirectory.appendingPathComponent("\(key).json")
    }

    func save(_ parsed: ParsedMarkdown, forKey key: String) throws {
        try parsed.save(to: cacheURL(for: key))
    }

    func load(forKey key: String) throws -> ParsedMarkdown {
        return try ParsedMarkdown.load(from: cacheURL(for: key))
    }

    func exists(forKey key: String) -> Bool {
        return FileManager.default.fileExists(atPath: cacheURL(for: key).path)
    }
}

// Usage
let cache = MarkdownCache()

// Parse and cache
let markdown = """
# Large Document
... lots of markdown content ...
"""

let parsed = ParsedMarkdown(markdown: markdown)
try cache.save(parsed, forKey: "article-123")

// Later, load from cache (no parsing needed!)
if cache.exists(forKey: "article-123") {
    let cached = try cache.load(forKey: "article-123")
    MarkdownView(parsed: cached)
}
```

## Example 2: UserDefaults Cache for Small Content

```swift
import BetterMarkdown

extension UserDefaults {
    func setParsedMarkdown(_ parsed: ParsedMarkdown, forKey key: String) throws {
        let data = try parsed.encode()
        set(data, forKey: key)
    }

    func parsedMarkdown(forKey key: String) throws -> ParsedMarkdown? {
        guard let data = data(forKey: key) else { return nil }
        return try ParsedMarkdown.decode(from: data)
    }
}

// Usage
let parsed = ParsedMarkdown(markdown: "# Welcome\nThis is cached!")
try UserDefaults.standard.setParsedMarkdown(parsed, forKey: "welcomeMessage")

// Later...
if let cached = try UserDefaults.standard.parsedMarkdown(forKey: "welcomeMessage") {
    MarkdownView(parsed: cached)
}
```

## Example 3: Network Response Caching

```swift
import BetterMarkdown

class ArticleLoader {
    func fetchArticle(id: String) async throws -> ParsedMarkdown {
        // Check cache first
        if let cached = try? loadFromCache(id: id) {
            return cached
        }

        // Fetch from network
        let url = URL(string: "https://api.example.com/articles/\(id)")!
        let (data, _) = try await URLSession.shared.data(from: url)

        // Parse markdown
        let markdown = String(data: data, encoding: .utf8) ?? ""
        let parsed = ParsedMarkdown(markdown: markdown)

        // Cache the parsed result
        try? saveToCache(parsed, id: id)

        return parsed
    }

    private func cacheURL(for id: String) -> URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return caches.appendingPathComponent("article-\(id).json")
    }

    private func saveToCache(_ parsed: ParsedMarkdown, id: String) throws {
        try parsed.save(to: cacheURL(for: id))
    }

    private func loadFromCache(id: String) throws -> ParsedMarkdown {
        try ParsedMarkdown.load(from: cacheURL(for: id))
    }
}

// Usage
let loader = ArticleLoader()
let article = try await loader.fetchArticle(id: "123")
MarkdownView(parsed: article)
```

## Example 4: SwiftUI with Async Loading & Cache

```swift
import SwiftUI
import BetterMarkdown

struct ArticleView: View {
    let articleID: String
    @State private var parsed: ParsedMarkdown?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let parsed = parsed {
                ScrollView {
                    MarkdownView(parsed: parsed)
                        .padding()
                }
            } else if isLoading {
                ProgressView("Loading...")
            } else {
                Text("Failed to load article")
            }
        }
        .task {
            await loadArticle()
        }
    }

    func loadArticle() async {
        // Try cache first
        if let cached = try? MarkdownCache().load(forKey: articleID) {
            parsed = cached
            isLoading = false
            return
        }

        // Fetch from network
        do {
            // Simulate network fetch
            let markdown = try await fetchFromNetwork(id: articleID)
            let parsed = ParsedMarkdown(markdown: markdown)

            // Cache it
            try? MarkdownCache().save(parsed, forKey: articleID)

            self.parsed = parsed
        } catch {
            print("Error: \(error)")
        }

        isLoading = false
    }

    func fetchFromNetwork(id: String) async throws -> String {
        // Your network code here
        return "# Network Article\nContent..."
    }
}
```

## Example 5: Equatable for Change Detection

```swift
import BetterMarkdown

class ArticleViewModel: ObservableObject {
    @Published var parsed: ParsedMarkdown

    init(markdown: String) {
        self.parsed = ParsedMarkdown(markdown: markdown)
    }

    func update(markdown: String) {
        let newParsed = ParsedMarkdown(markdown: markdown)

        // Only update if content actually changed
        if newParsed != parsed {
            parsed = newParsed
            print("Content changed, re-rendering")
        } else {
            print("Content unchanged, skipping update")
        }
    }
}

// SwiftUI automatically re-renders only when needed
struct ContentView: View {
    @StateObject var viewModel: ArticleViewModel

    var body: some View {
        MarkdownView(parsed: viewModel.parsed)
    }
}
```

## Performance Tips

1. **Cache aggressively**: Parsing is the expensive part. Cache `ParsedMarkdown` whenever possible.

2. **Use file cache for large content**: UserDefaults is better for small data. Use file system for articles/documents.

3. **Pre-parse on background thread**:
   ```swift
   Task.detached {
       let parsed = ParsedMarkdown(markdown: largeMarkdown)
       await MainActor.run {
           self.parsed = parsed
       }
   }
   ```

4. **Cache invalidation**: Add timestamps or version numbers to your cache keys:
   ```swift
   let cacheKey = "article-\(id)-v\(version)"
   ```

5. **Memory cache + Disk cache**: Keep frequently accessed items in memory:
   ```swift
   class MarkdownCache {
       private var memoryCache: [String: ParsedMarkdown] = [:]

       func get(key: String) -> ParsedMarkdown? {
           // Check memory first
           if let cached = memoryCache[key] {
               return cached
           }

           // Then disk
           if let cached = try? ParsedMarkdown.load(from: cacheURL(for: key)) {
               memoryCache[key] = cached
               return cached
           }

           return nil
       }
   }
   ```
