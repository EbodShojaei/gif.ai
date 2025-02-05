import SwiftUI
import UniformTypeIdentifiers

@MainActor
class GifDetailViewModel: ObservableObject {
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var temporaryFileURL: URL?
    @Published var isLoading = false
    
    func copyGIFToClipboard(_ gifData: Data) {
        GifClipboardManager.shared.copyToClipboard(gifData)
        showAlert(title: "Success", message: "GIF copied to clipboard!")
    }
    
    func prepareForSharing(_ data: Data) {
        isLoading = true
        Task {
            temporaryFileURL = GifFileManager.shared.createTemporaryGIFFile(from: data)
            isLoading = false
        }
    }
    
    func cleanup() {
        if let url = temporaryFileURL {
            GifFileManager.shared.cleanupFile(at: url)
            temporaryFileURL = nil
        }
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}
