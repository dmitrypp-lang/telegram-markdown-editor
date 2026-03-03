// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TelegramMarkdownEditor",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "TelegramMarkdownEditor", targets: ["TelegramMarkdownEditor"])
    ],
    targets: [
        .executableTarget(
            name: "TelegramMarkdownEditor",
            path: "Sources/TelegramMarkdownEditor"
        )
    ]
)
