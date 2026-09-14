import SwiftUI

/// Root tabs for the assignment MVP.
/// Home, Map, and Post are required. Saved is a placeholder until those three work.
struct ContentView: View {
    var body: some View {
        TabView {
            HomePlaceholderView()
                .tabItem {
                    Label("Home", systemImage: "list.bullet")
                }

            MapPlaceholderView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            PostPlaceholderView()
                .tabItem {
                    Label("Post", systemImage: "plus.circle")
                }

            SavedPlaceholderView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
        }
    }
}

struct HomePlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Campus events will appear here",
                systemImage: "sparkles",
                description: Text("Phase 0 placeholder. The feed connects to the backend in a later phase.")
            )
            .navigationTitle("CampusPulse")
        }
    }
}

struct MapPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Map coming next",
                systemImage: "map",
                description: Text("MapKit pins and your location will be added after the feed and API work.")
            )
            .navigationTitle("Map")
        }
    }
}

struct PostPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Create an event",
                systemImage: "plus.circle",
                description: Text("The post form will send user-generated events to the backend.")
            )
            .navigationTitle("Post")
        }
    }
}

struct SavedPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Saved events",
                systemImage: "bookmark",
                description: Text("Optional for the MVP. Left as a simple placeholder.")
            )
            .navigationTitle("Saved")
        }
    }
}

#Preview {
    ContentView()
}
