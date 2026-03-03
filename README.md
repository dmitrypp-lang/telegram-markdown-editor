# Telegram Markdown Editor (macOS AppKit)

Telegram Markdown Editor is a native macOS desktop utility for writing and converting Telegram-formatted messages.

- **Platform:** macOS 10.15+
- **UI framework:** AppKit (no SwiftUI)
- **Project format:** Swift Package Manager project that opens directly in Xcode

## Features

- Split layout: Markdown editor + Telegram preview
- Syntax highlighting for Telegram markdown markers
- Live preview rendering (Markdown → HTML)
- Markdown validation:
  - unbalanced formatting markers
  - possible broken links
  - unescaped MarkdownV2 reserved characters
- Auto fix button for Telegram MarkdownV2 escaping
- Clipboard tools via `NSPasteboard`:
  - Paste from Telegram (`html`, `rtf`, `string`)
  - Copy for Telegram (plain markdown)
  - Copy for Word / Docs (RTF + plain text)
- Conversion tools:
  - Markdown → Rich Text
  - Rich Text → Markdown
- Character counter with 4096 limit warning
- Split long posts command (keeps text within Telegram per-message cap)
- Toolbar buttons and keyboard shortcuts:
  - Cmd+B, Cmd+I, Cmd+K
  - Cmd+Shift+C (Copy Telegram Markdown)

## Architecture

```
Sources/TelegramMarkdownEditor/
  Core/
    MarkdownParser.swift
    MarkdownValidator.swift
    MarkdownConverter.swift
  UI/
    EditorViewController.swift
    PreviewViewController.swift
    ToolbarController.swift
  Services/
    ClipboardManager.swift
    MarkdownFormatter.swift
    PostSplitter.swift
  main.swift
```

- `Core` has no UI dependencies.
- `Services` encapsulate clipboard and Telegram-specific transformations.
- `UI` handles AppKit views/controllers and toolbar.

## Build and run

### Xcode

1. Open `Package.swift` in Xcode.
2. Select the `TelegramMarkdownEditor` scheme.
3. Build and run (`⌘R`).

### CLI

```bash
swift build
swift run TelegramMarkdownEditor
```

## Development stages completed

1. Basic window + Markdown editor
2. Preview rendering
3. Markdown validator
4. Clipboard integration
5. Toolbar + shortcuts
6. Telegram-specific tools (fix/split/counter)

## Notes

- The preview renderer is intentionally lightweight and focused on Telegram formatting patterns.
- The project is structured for extension (e.g., improved parser, richer validation, file open/save, drag & drop).
