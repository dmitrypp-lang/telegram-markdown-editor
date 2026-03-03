import AppKit
import WebKit

final class PreviewViewController: NSViewController {
    private let webView = WKWebView()

    override func loadView() {
        self.view = webView
    }

    func render(html: String) {
        webView.loadHTMLString(html, baseURL: nil)
    }
}
