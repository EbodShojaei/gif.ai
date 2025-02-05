import SwiftUI

struct GifRowView: View {
    @Bindable var gif: GifItem
    @State private var isLoading = true
    
    var body: some View {
        HStack {
            if let gifData = Data(base64Encoded: gif.base64Data) {
                GifView(data: gifData)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        if isLoading {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.ultraThinMaterial)
                                .overlay {
                                    LoadingView()
                                        .scaleEffect(0.7)
                                }
                        }
                    }
                    .onAppear {
                        // Simulate brief loading time to show animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isLoading = false
                        }
                    }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay {
                        LoadingView()
                            .scaleEffect(0.7)
                    }
            }
            
            VStack(alignment: .leading) {
                Text(gif.prompt)
                    .lineLimit(2)
                Text(gif.createdAt.formatted())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button(action: { gif.isFavorite.toggle() }) {
                Image(systemName: gif.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(gif.isFavorite ? .yellow : .gray)
            }
        }
        .padding(.vertical, 4)
    }
}
