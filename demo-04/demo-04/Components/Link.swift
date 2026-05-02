import SwiftUI
import WebKit

struct Link: Identifiable {
    let id = UUID()
    let text: String
    let url: String
}

struct LinkHelper: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}