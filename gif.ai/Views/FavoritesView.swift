import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<GifItem> { gif in
        gif.isFavorite == true
    }, sort: \GifItem.createdAt, order: .reverse) private var favoriteGifs: [GifItem]
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    LoadingView()
                } else if favoriteGifs.isEmpty {
                    ContentUnavailableView(
                        "No Favorites",
                        systemImage: "star",
                        description: Text("Your favorite GIFs will appear here")
                    )
                } else {
                    List {
                        ForEach(favoriteGifs) { gif in
                            NavigationLink(destination: GifDetailView(gif: gif)) {
                                GifRowView(gif: gif)
                            }
                        }
                        .onDelete(perform: deleteGifs)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Favorites")
            .toolbar {
                if !favoriteGifs.isEmpty {
                    EditButton()
                }
            }
        }
        .onAppear {
            // Simulate brief loading time
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isLoading = false
            }
        }
    }
    
    private func deleteGifs(at offsets: IndexSet) {
        for index in offsets {
            let gif = favoriteGifs[index]
            // Option 1: Remove from favorites
            gif.isFavorite = false
            // Option 2: Delete completely
            // modelContext.delete(gif)
        }
        
        // Save changes
        try? modelContext.save()
    }
}
