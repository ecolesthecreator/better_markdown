// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BetterMarkdown",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "BetterMarkdown",
            targets: ["BetterMarkdown"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-markdown.git", branch: "main"),
        .package(url: "https://github.com/raspu/Highlightr.git", from: "2.1.0")
    ],
    targets: [
        .target(
            name: "BetterMarkdown",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                "Highlightr"
            ]
        ),
        .testTarget(
            name: "BetterMarkdownTests",
            dependencies: ["BetterMarkdown"]
        ),
    ]
)
