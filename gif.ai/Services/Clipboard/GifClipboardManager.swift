import UIKit
import UniformTypeIdentifiers

class GifClipboardManager {
    static let shared = GifClipboardManager()
    private init() {}
    
    func copyToClipboard(_ data: Data) {
        UIPasteboard.general.setData(data, forPasteboardType: UTType.gif.identifier)
    }
}
