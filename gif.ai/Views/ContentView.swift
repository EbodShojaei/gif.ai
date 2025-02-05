import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        ZStack {
            // TabView on top of the background
            TabView {
                HomeView()
                    .tabItem {
                        Label("Create", systemImage: "wand.and.stars")
                    }
                
                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "book")
                    }
                
                FavoritesView()
                    .tabItem {
                        Label("Favorites", systemImage: "star")
                    }
            }
            .accentColor(Color("AccentColor")) // Sets the accent color for the TabView
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: GifItem.self, inMemory: true)
}
