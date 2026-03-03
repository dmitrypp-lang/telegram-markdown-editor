import AppKit

final class ClipboardManager {
    private let converter = MarkdownConverter()

    func pasteFromTelegram() -> String? {
        let pasteboard = NSPasteboard.general

        if let html = pasteboard.string(forType: .html) {
            return converter.htmlToMarkdown(html)
        }
        if let rtf = pasteboard.data(forType: .rtf),
           let attributed = try? NSAttributedString(data: rtf, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil) {
            return converter.richTextToMarkdown(attributed)
        }
        return pasteboard.string(forType: .string)
    }

    func copyTelegramMarkdown(_ text: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
    }

    func copyForWordOrDocs(markdown: String) {
        let attributed = converter.markdownToRichText(markdown)
        let range = NSRange(location: 0, length: attributed.length)
        let pb = NSPasteboard.general
        pb.clearContents()
        if let rtf = try? attributed.data(from: range, documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]) {
            pb.setData(rtf, forType: .rtf)
        }
        pb.setString(markdown, forType: .string)
    }
}
