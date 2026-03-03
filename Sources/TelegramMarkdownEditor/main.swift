import AppKit

final class MainWindowController: NSWindowController, EditorViewControllerDelegate, ToolbarControllerDelegate {
    private let editorVC = EditorViewController()
    private let previewVC = PreviewViewController()
    private let toolbarController = ToolbarController()

    private let parser = MarkdownParser()
    private let converter = MarkdownConverter()
    private let validator = MarkdownValidator()
    private let formatter = MarkdownFormatter()
    private let clipboard = ClipboardManager()
    private let splitter = PostSplitter()

    private let statusLabel = NSTextField(labelWithString: "Characters: 0 / 4096")

    convenience init() {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1100, height: 700),
                              styleMask: [.titled, .resizable, .closable, .miniaturizable],
                              backing: .buffered,
                              defer: false)
        self.init(window: window)
        configureWindow()
    }

    private func configureWindow() {
        guard let window else { return }
        window.title = "Telegram Markdown Editor"

        let splitView = NSSplitView()
        splitView.dividerStyle = .thin
        splitView.isVertical = true
        splitView.translatesAutoresizingMaskIntoConstraints = false

        editorVC.delegate = self
        splitView.addArrangedSubview(editorVC.view)
        splitView.addArrangedSubview(previewVC.view)

        let statusContainer = NSView()
        statusContainer.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusContainer.addSubview(statusLabel)
        NSLayoutConstraint.activate([
            statusLabel.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 12),
            statusLabel.centerYAnchor.constraint(equalTo: statusContainer.centerYAnchor)
        ])

        let stack = NSStackView(views: [splitView, statusContainer])
        stack.orientation = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 0
        stack.setHuggingPriority(.defaultLow, for: .vertical)
        statusContainer.heightAnchor.constraint(equalToConstant: 28).isActive = true

        let root = NSView()
        root.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            stack.topAnchor.constraint(equalTo: root.topAnchor),
            stack.bottomAnchor.constraint(equalTo: root.bottomAnchor)
        ])

        window.contentView = root

        toolbarController.delegate = self
        window.toolbar = toolbarController.makeToolbar()

        buildMenu()
        editorVC.setText("Welcome to Telegram Markdown Editor\n\nType **bold**, *italic*, __underline__, ~~strikethrough~~, `code`, [links](https://telegram.org), and ||spoilers||.")
    }

    func editorDidChange(text: String) {
        previewVC.render(html: converter.markdownToHTML(text))
        let count = text.count
        statusLabel.stringValue = "Characters: \(count) / 4096"
        statusLabel.textColor = count > 4096 ? .systemRed : .secondaryLabelColor
        applySyntaxHighlighting(text: text)
        applyValidationHighlights(text: text)
    }


    private func applySyntaxHighlighting(text: String) {
        guard let storage = editorVC.textView.textStorage else { return }
        let full = NSRange(location: 0, length: storage.length)
        storage.removeAttribute(.foregroundColor, range: full)
        storage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: full)

        let rules: [(String, NSColor)] = [
            ("\\*\\*[^*]+\\*\\*", .systemBlue),
            ("(?<!\\*)\\*[^*]+\\*(?!\\*)", .systemTeal),
            ("__[^_]+__", .systemPurple),
            ("~~[^~]+~~", .systemOrange),
            ("`[^`]+`", .systemGreen),
            ("\\[([^\\]]+)\\]\\(([^)]+)\\)", .systemPink),
            ("\\|\\|[^|]+\\|\\|", .systemBrown)
        ]

        for (pattern, color) in rules {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
            let ns = text as NSString
            for match in regex.matches(in: text, range: NSRange(location: 0, length: ns.length)) {
                storage.addAttribute(.foregroundColor, value: color, range: match.range)
            }
        }
    }

    private func applyValidationHighlights(text: String) {
        let storage = editorVC.textView.textStorage
        let full = NSRange(location: 0, length: storage?.length ?? 0)
        storage?.removeAttribute(.backgroundColor, range: full)
        let issues = validator.validate(text)
        for issue in issues {
            storage?.addAttribute(.backgroundColor, value: NSColor.systemRed.withAlphaComponent(0.22), range: issue.range)
        }
        editorVC.textView.toolTip = issues.map(\.message).joined(separator: "\n")
    }

    func toolbarAction(_ action: ToolbarController.Action) {
        switch action {
        case .bold: applyToken("**")
        case .italic: applyToken("*")
        case .underline: applyToken("__")
        case .strikethrough: applyToken("~~")
        case .code: applyToken("`")
        case .link: applyLink()
        case .fixMarkdown:
            editorVC.setText(formatter.escapeMarkdownV2(editorVC.textView.string))
        case .copyTelegram:
            clipboard.copyTelegramMarkdown(editorVC.textView.string)
        case .pasteTelegram:
            if let text = clipboard.pasteFromTelegram() { editorVC.setText(text) }
        case .copyWord:
            clipboard.copyForWordOrDocs(markdown: editorVC.textView.string)
        case .splitPosts:
            showSplitResult()
        }
    }

    private func applyToken(_ token: String) {
        let (text, range) = parser.apply(token: token, to: editorVC.textView.string, selectedRange: editorVC.textView.selectedRange())
        editorVC.apply(newText: text, selection: range)
    }

    private func applyLink() {
        let (text, range) = parser.applyLink(to: editorVC.textView.string, selectedRange: editorVC.textView.selectedRange())
        editorVC.apply(newText: text, selection: range)
    }

    private func showSplitResult() {
        let posts = splitter.split(editorVC.textView.string)
        guard posts.count > 1 else { return }
        let alert = NSAlert()
        alert.messageText = "Split into \(posts.count) Telegram posts"
        alert.informativeText = posts.enumerated().map { "Post \($0.offset + 1) (\($0.element.count) chars)" }.joined(separator: "\n")
        alert.runModal()
    }

    private func buildMenu() {
        let mainMenu = NSMenu()
        NSApp.mainMenu = mainMenu

        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenuItem.submenu = appMenu
        appMenu.addItem(withTitle: "Quit Telegram Markdown Editor", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        let editItem = NSMenuItem()
        mainMenu.addItem(editItem)
        let editMenu = NSMenu(title: "Edit")
        editItem.submenu = editMenu

        editMenu.addItem(withTitle: "Bold", action: #selector(commandBold), keyEquivalent: "b").keyEquivalentModifierMask = [.command]
        editMenu.addItem(withTitle: "Italic", action: #selector(commandItalic), keyEquivalent: "i").keyEquivalentModifierMask = [.command]
        editMenu.addItem(withTitle: "Insert Link", action: #selector(commandLink), keyEquivalent: "k").keyEquivalentModifierMask = [.command]
        editMenu.addItem(withTitle: "Copy Telegram Markdown", action: #selector(commandCopyTelegram), keyEquivalent: "C").keyEquivalentModifierMask = [.command, .shift]
    }

    @objc private func commandBold() { toolbarAction(.bold) }
    @objc private func commandItalic() { toolbarAction(.italic) }
    @objc private func commandLink() { toolbarAction(.link) }
    @objc private func commandCopyTelegram() { toolbarAction(.copyTelegram) }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowController: MainWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        windowController = MainWindowController()
        windowController?.showWindow(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.activate(ignoringOtherApps: true)
app.run()

