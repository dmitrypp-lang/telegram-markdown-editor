import AppKit

protocol ToolbarControllerDelegate: AnyObject {
    func toolbarAction(_ action: ToolbarController.Action)
}

final class ToolbarController: NSObject, NSToolbarDelegate {
    enum Action: String {
        case bold, italic, underline, strikethrough, code, link
        case fixMarkdown, copyTelegram, pasteTelegram, copyWord, splitPosts
    }

    weak var delegate: ToolbarControllerDelegate?

    func makeToolbar() -> NSToolbar {
        let toolbar = NSToolbar(identifier: "TelegramMarkdownToolbar")
        toolbar.displayMode = .iconAndLabel
        toolbar.delegate = self
        return toolbar
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.init("bold"), .init("italic"), .init("underline"), .init("strikethrough"), .init("code"), .init("link"), .flexibleSpace, .init("fixMarkdown"), .init("copyTelegram"), .init("pasteTelegram"), .init("copyWord"), .init("splitPosts")]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarAllowedItemIdentifiers(toolbar)
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        makeItem(id: itemIdentifier.rawValue)
    }

    private func makeItem(id: String) -> NSToolbarItem {
        let item = NSToolbarItem(itemIdentifier: .init(id))
        item.target = self
        item.action = #selector(handleAction(_:))
        item.label = label(for: id)
        item.paletteLabel = item.label
        item.toolTip = item.label
        item.image = image(for: id)
        return item
    }

    @objc private func handleAction(_ sender: NSToolbarItem) {
        guard let action = Action(rawValue: sender.itemIdentifier.rawValue) else { return }
        delegate?.toolbarAction(action)
    }

    private func label(for id: String) -> String {
        switch id {
        case "bold": return "Bold"
        case "italic": return "Italic"
        case "underline": return "Underline"
        case "strikethrough": return "Strike"
        case "code": return "Code"
        case "link": return "Link"
        case "fixMarkdown": return "Fix Markdown"
        case "copyTelegram": return "Copy Telegram"
        case "pasteTelegram": return "Paste Telegram"
        case "copyWord": return "Copy Word/Docs"
        case "splitPosts": return "Split Posts"
        default: return id
        }
    }

    private func image(for id: String) -> NSImage? {
        switch id {
        case "bold": return NSImage(systemSymbolName: "bold", accessibilityDescription: nil)
        case "italic": return NSImage(systemSymbolName: "italic", accessibilityDescription: nil)
        case "underline": return NSImage(systemSymbolName: "underline", accessibilityDescription: nil)
        case "strikethrough": return NSImage(systemSymbolName: "strikethrough", accessibilityDescription: nil)
        case "code": return NSImage(systemSymbolName: "chevron.left.forwardslash.chevron.right", accessibilityDescription: nil)
        case "link": return NSImage(systemSymbolName: "link", accessibilityDescription: nil)
        case "fixMarkdown": return NSImage(systemSymbolName: "wand.and.stars", accessibilityDescription: nil)
        case "copyTelegram": return NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: nil)
        case "pasteTelegram": return NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: nil)
        case "copyWord": return NSImage(systemSymbolName: "doc.richtext", accessibilityDescription: nil)
        case "splitPosts": return NSImage(systemSymbolName: "square.split.2x1", accessibilityDescription: nil)
        default: return nil
        }
    }
}
