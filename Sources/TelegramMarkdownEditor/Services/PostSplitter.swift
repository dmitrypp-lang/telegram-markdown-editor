import Foundation

struct PostSplitter {
    let maxLength = 4096

    func split(_ text: String) -> [String] {
        guard text.count > maxLength else { return [text] }
        var result: [String] = []
        var current = ""
        for line in text.split(separator: "\n", omittingEmptySubsequences: false) {
            let candidate = current.isEmpty ? String(line) : current + "\n" + line
            if candidate.count > maxLength {
                if !current.isEmpty { result.append(current) }
                if line.count > maxLength {
                    result.append(contentsOf: chunk(String(line), size: maxLength))
                    current = ""
                } else {
                    current = String(line)
                }
            } else {
                current = candidate
            }
        }
        if !current.isEmpty { result.append(current) }
        return result
    }

    private func chunk(_ text: String, size: Int) -> [String] {
        var output: [String] = []
        var start = text.startIndex
        while start < text.endIndex {
            let end = text.index(start, offsetBy: size, limitedBy: text.endIndex) ?? text.endIndex
            output.append(String(text[start..<end]))
            start = end
        }
        return output
    }
}
