import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GifItem.createdAt, order: .reverse) private var gifs: [GifItem]
    @State private var isLoading = true
    
    private var recentGifs: [GifItem] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return gifs.filter { $0.createdAt > sevenDaysAgo }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading {
                    LoadingView()
                } else if recentGifs.isEmpty {
                    ContentUnavailableView(
                        "No History",
                        systemImage: "clock",
                        description: Text("Generated GIFs from the last 7 days will appear here")
                    )
                } else {
                    List {
                        ForEach(recentGifs) { gif in
                            NavigationLink(destination: GifDetailView(gif: gif)) {
                                GifRowView(gif: gif)
                            }
                        }
                        .onDelete(perform: deleteGifs)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("History")
            .toolbar {
                if !recentGifs.isEmpty {
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
            let gif = recentGifs[index]
            modelContext.delete(gif)
        }
        
        // Save changes
        try? modelContext.save()
    }
}
#Preview {
    HistoryView()
        .modelContainer(for: GifItem.self, inMemory: true)
}
