import Foundation

struct MarkdownFormatter {
    private let charsToEscape = Array("_*[]()~`>#+-=|{}.!")

    func escapeMarkdownV2(_ text: String) -> String {
        var result = ""
        for ch in text {
            if charsToEscape.contains(ch) {
                result.append("\\")
            }
            result.append(ch)
        }
        return result
    }
}
