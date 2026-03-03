import Foundation

struct ValidationIssue {
    let message: String
    let range: NSRange
}

struct MarkdownValidator {
    private let reserved = CharacterSet(charactersIn: "_ * [ ] ( ) ~ ` > # + - = | { } . !".replacingOccurrences(of: " ", with: ""))

    func validate(_ text: String) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        issues.append(contentsOf: checkUnbalanced(text, token: "**", name: "bold markers"))
        issues.append(contentsOf: checkUnbalanced(text, token: "*", name: "italic markers"))
        issues.append(contentsOf: checkUnbalanced(text, token: "__", name: "underline markers"))
        issues.append(contentsOf: checkUnbalanced(text, token: "~~", name: "strikethrough markers"))
        issues.append(contentsOf: checkUnbalanced(text, token: "`", name: "inline code markers"))
        issues.append(contentsOf: checkUnbalanced(text, token: "||", name: "spoiler markers"))
        issues.append(contentsOf: checkBrokenLinks(text))
        issues.append(contentsOf: checkUnescapedReservedChars(text))
        return issues
    }

    private func checkUnbalanced(_ text: String, token: String, name: String) -> [ValidationIssue] {
        let count = text.components(separatedBy: token).count - 1
        guard count % 2 != 0 else { return [] }
        return [ValidationIssue(message: "Unbalanced \(name)", range: NSRange(location: 0, length: (text as NSString).length))]
    }

    private func checkBrokenLinks(_ text: String) -> [ValidationIssue] {
        let pattern = "\\[[^\\]]+\\]\\([^\\)]+$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let ns = text as NSString
        return regex.matches(in: text, range: NSRange(location: 0, length: ns.length)).map {
            ValidationIssue(message: "Possibly broken link", range: $0.range)
        }
    }

    private func checkUnescapedReservedChars(_ text: String) -> [ValidationIssue] {
        var issues: [ValidationIssue] = []
        let scalars = Array(text.unicodeScalars)
        for (idx, scalar) in scalars.enumerated() where reserved.contains(scalar) {
            let isEscaped = idx > 0 && scalars[idx - 1] == "\\"
            if !isEscaped {
                issues.append(ValidationIssue(message: "Unescaped Telegram MarkdownV2 character '\(Character(scalar))'", range: NSRange(location: idx, length: 1)))
            }
        }
        return issues
    }
}
