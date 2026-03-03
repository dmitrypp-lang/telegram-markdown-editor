import Foundation

struct MarkdownConverter {
    func markdownToHTML(_ markdown: String) -> String {
        var html = escapeHTML(markdown)

        // Code blocks first
        html = replace(pattern: "```([\\s\\S]*?)```", in: html) { groups in
            "<pre><code>\(groups[1])</code></pre>"
        }
        // Inline code
        html = replace(pattern: "`([^`]+)`", in: html) { groups in
            "<code>\(groups[1])</code>"
        }
        // Spoiler
        html = replace(pattern: "\\|\\|([^|]+)\\|\\|", in: html) { groups in
            "<span class=\"spoiler\">\(groups[1])</span>"
        }
        // Link
        html = replace(pattern: "\\[([^\\]]+)\\]\\(([^)]+)\\)", in: html) { groups in
            "<a href=\"\(groups[2])\">\(groups[1])</a>"
        }
        // Bold
        html = replace(pattern: "\\*\\*([^*]+)\\*\\*", in: html) { groups in
            "<strong>\(groups[1])</strong>"
        }
        // Underline
        html = replace(pattern: "__([^_]+)__", in: html) { groups in
            "<u>\(groups[1])</u>"
        }
        // Italic
        html = replace(pattern: "(?<!\\*)\\*([^*]+)\\*(?!\\*)", in: html) { groups in
            "<em>\(groups[1])</em>"
        }
        // Strikethrough
        html = replace(pattern: "~~([^~]+)~~", in: html) { groups in
            "<s>\(groups[1])</s>"
        }

        html = html.replacingOccurrences(of: "\n", with: "<br>")
        return wrappedDocument(body: html)
    }

    func htmlToMarkdown(_ html: String) -> String {
        var markdown = html
        let replacements: [(String, String)] = [
            ("<strong>(.*?)</strong>", "**$1**"),
            ("<b>(.*?)</b>", "**$1**"),
            ("<em>(.*?)</em>", "*$1*"),
            ("<i>(.*?)</i>", "*$1*"),
            ("<u>(.*?)</u>", "__$1__"),
            ("<s>(.*?)</s>", "~~$1~~"),
            ("<code>(.*?)</code>", "`$1`"),
            ("<span class=\"spoiler\">(.*?)</span>", "||$1||"),
            ("<br\\s*/?>", "\n")
        ]

        for (pattern, replacement) in replacements {
            markdown = regexReplace(pattern: pattern, in: markdown, with: replacement)
        }

        markdown = replace(pattern: "<a href=\"(.*?)\">(.*?)</a>", in: markdown) { g in
            "[\(g[2])](\(g[1]))"
        }

        markdown = regexReplace(pattern: "<[^>]+>", in: markdown, with: "")
        return markdown
    }

    func markdownToRichText(_ markdown: String) -> NSAttributedString {
        let html = markdownToHTML(markdown)
        let data = Data(html.utf8)
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        return (try? NSAttributedString(data: data, options: options, documentAttributes: nil)) ?? NSAttributedString(string: markdown)
    }

    func richTextToMarkdown(_ attributed: NSAttributedString) -> String {
        let range = NSRange(location: 0, length: attributed.length)
        let options: [NSAttributedString.DocumentAttributeKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        let data = (try? attributed.data(from: range, documentAttributes: options)) ?? Data()
        let html = String(data: data, encoding: .utf8) ?? ""
        return htmlToMarkdown(html)
    }

    private func wrappedDocument(body: String) -> String {
        """
        <html>
        <head>
          <meta charset="utf-8" />
          <style>
            body { font-family: -apple-system; font-size: 14px; padding: 12px; color: -apple-system-label; background: transparent; }
            code { font-family: Menlo, monospace; background: rgba(127,127,127,0.16); padding: 2px 4px; border-radius: 4px; }
            pre { background: rgba(127,127,127,0.16); padding: 8px; border-radius: 6px; overflow-x: auto; }
            .spoiler { background: rgba(127,127,127,0.5); color: transparent; border-radius: 3px; padding: 0 2px; }
            .spoiler:hover { color: inherit; }
            a { color: #0A84FF; text-decoration: underline; }
          </style>
        </head>
        <body>\(body)</body>
        </html>
        """
    }

    private func escapeHTML(_ input: String) -> String {
        input
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    private func replace(pattern: String, in text: String, transform: ([String]) -> String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return text }
        let nsText = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length))
        var result = text
        for match in matches.reversed() {
            var groups: [String] = []
            for i in 0..<match.numberOfRanges {
                let r = match.range(at: i)
                groups.append(r.location != NSNotFound ? nsText.substring(with: r) : "")
            }
            let replacement = transform(groups)
            if let range = Range(match.range, in: result) {
                result.replaceSubrange(range, with: replacement)
            }
        }
        return result
    }

    private func regexReplace(pattern: String, in text: String, with replacement: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) else {
            return text
        }
        return regex.stringByReplacingMatches(in: text, options: [], range: NSRange(location: 0, length: (text as NSString).length), withTemplate: replacement)
    }
}
