import SwiftUI
import WebKit
import AVKit

struct GifView: View {
    let data: Data
    @State private var player: AVPlayer?
    
    var body: some View {
        Group {
            if isGIF(data) {
                GifWebView(data: data)
            } else {
                VideoPlayer(player: player)
                    .onAppear {
                        // Save video data to temporary file
                        let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mp4")
                        try? data.write(to: temporaryURL)
                        player = AVPlayer(url: temporaryURL)
                        player?.play()
                    }
                    .onDisappear {
                        player?.pause()
                        player = nil
                    }
            }
        }
    }
    
    private func isGIF(_ data: Data) -> Bool {
        let gifSignatures = ["GIF87a", "GIF89a"]
        guard let prefix = String(data: data.prefix(6), encoding: .ascii) else { return false }
        return gifSignatures.contains(prefix)
    }
}

struct GifWebView: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".gif")
        try? data.write(to: temporaryURL)
        webView.loadFileURL(temporaryURL, allowingReadAccessTo: temporaryURL.deletingLastPathComponent())
    }
}
