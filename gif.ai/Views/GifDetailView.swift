import SwiftUI
import SwiftData
import UIKit
import UniformTypeIdentifiers

struct GifDetailView: View {
    @Bindable var gif: GifItem
    @StateObject private var viewModel = GifDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let gifData = Data(base64Encoded: gif.base64Data) {
                    GifView(data: gifData)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            if viewModel.isLoading {
                                ZStack {
                                    Rectangle()
                                        .fill(.ultraThinMaterial)
                                    LoadingView()
                                }
                            }
                        }
                    
                    Text(gif.prompt)
                        .font(.body)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    Button(action: { gif.isFavorite.toggle() }) {
                        Label(
                            gif.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                            systemImage: gif.isFavorite ? "star.fill" : "star"
                        )
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        viewModel.copyGIFToClipboard(gifData)
                    }) {
                        Label("Copy to Clipboard", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.bordered)
                    
                    if let fileURL = viewModel.temporaryFileURL {
                        ShareLink(
                            item: fileURL,
                            preview: SharePreview(
                                "Share GIF",
                                image: gifData
                            )
                        )
                        .buttonStyle(.bordered)
                    } else if viewModel.isLoading {
                        Button(action: {}) {
                            Label("Preparing Share...", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)
                        .disabled(true)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("GIF Detail")
        .navigationBarTitleDisplayMode(.inline)
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            Button("OK") { }
        } message: {
            Text(viewModel.alertMessage)
        }
        .onAppear {
            if let gifData = Data(base64Encoded: gif.base64Data) {
                viewModel.prepareForSharing(gifData)
            }
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}
