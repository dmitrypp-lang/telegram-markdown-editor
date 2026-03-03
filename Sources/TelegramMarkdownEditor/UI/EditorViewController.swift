import AppKit

protocol EditorViewControllerDelegate: AnyObject {
    func editorDidChange(text: String)
}

final class EditorViewController: NSViewController, NSTextViewDelegate {
    weak var delegate: EditorViewControllerDelegate?
    let textView = NSTextView()

    override func loadView() {
        let scroll = NSScrollView()
        scroll.hasVerticalScroller = true
        scroll.hasHorizontalScroller = false
        scroll.autohidesScrollers = true

        textView.isRichText = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDataDetectionEnabled = false
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.delegate = self
        textView.allowsUndo = true

        scroll.documentView = textView
        self.view = scroll
    }

    func textDidChange(_ notification: Notification) {
        delegate?.editorDidChange(text: textView.string)
    }

    func setText(_ text: String) {
        textView.string = text
        delegate?.editorDidChange(text: text)
    }

    func apply(newText: String, selection: NSRange) {
        textView.string = newText
        textView.setSelectedRange(selection)
        delegate?.editorDidChange(text: newText)
    }
}
