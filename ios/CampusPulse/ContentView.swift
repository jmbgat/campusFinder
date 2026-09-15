import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "list.bullet") }
            EventMapView()
                .tabItem { Label("Map", systemImage: "map") }
            CreateEventView()
                .tabItem { Label("Post", systemImage: "plus.circle") }
            SavedEventsView()
                .tabItem { Label("Saved", systemImage: "bookmark") }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(EventStore())
        .environmentObject(LocationManager())
}
