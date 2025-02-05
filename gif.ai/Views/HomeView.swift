import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var prompt: String = ""
    @State private var isGenerating = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var progress = ""
    @State private var generatedGif: GifItem?
    @State private var navigateToGif = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Enter your prompt...", text: $prompt, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(5)
                    .padding()
                
                if !progress.isEmpty {
                    Text(progress)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Button(action: generateGif) {
                    if isGenerating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Generate GIF")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(prompt.isEmpty || isGenerating)
                
                Spacer()
            }
            .navigationTitle("Create GIF")
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .navigationDestination(isPresented: $navigateToGif) {
                if let gif = generatedGif {
                    GifDetailView(gif: gif)
                }
            }
        }
    }
    
    private func generateGif() {
        isGenerating = true
        progress = "Starting generation..."
        
        Task {
            do {
                progress = "Sending request to API..."
                let data = try await APIService.shared.generateGif(prompt: prompt)
                progress = "Processing response..."
                let base64String = data.base64EncodedString()
                
                let newGif = GifItem(
                    prompt: prompt,
                    base64Data: base64String
                )
                modelContext.insert(newGif)
                try modelContext.save()
                
                await MainActor.run {
                    generatedGif = newGif
                    prompt = ""
                    isGenerating = false
                    progress = ""
                    navigateToGif = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isGenerating = false
                    progress = ""
                }
            }
        }
    }
}
#Preview {
    HomeView()
        .modelContainer(for: GifItem.self, inMemory: true)
}
