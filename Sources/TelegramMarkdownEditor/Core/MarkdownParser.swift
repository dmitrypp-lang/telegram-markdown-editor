import Foundation

struct MarkdownParser {
    func apply(token: String, to text: String, selectedRange: NSRange) -> (String, NSRange) {
        let ns = text as NSString
        let safeRange = NSIntersectionRange(selectedRange, NSRange(location: 0, length: ns.length))
        let selected = ns.substring(with: safeRange)
        let replacement = "\(token)\(selected)\(token)"
        let updated = ns.replacingCharacters(in: safeRange, with: replacement)
        let newRange = NSRange(location: safeRange.location + token.count, length: safeRange.length)
        return (updated, newRange)
    }

    func applyLink(to text: String, selectedRange: NSRange) -> (String, NSRange) {
        let ns = text as NSString
        let safeRange = NSIntersectionRange(selectedRange, NSRange(location: 0, length: ns.length))
        let selected = ns.substring(with: safeRange)
        let title = selected.isEmpty ? "text" : selected
        let replacement = "[\(title)](https://example.com)"
        let updated = ns.replacingCharacters(in: safeRange, with: replacement)
        return (updated, NSRange(location: safeRange.location + 1, length: title.count))
    }
}
