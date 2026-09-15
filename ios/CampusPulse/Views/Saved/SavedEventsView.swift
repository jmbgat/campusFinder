import SwiftUI

struct SavedEventsView: View {
    @EnvironmentObject private var store: EventStore
    @EnvironmentObject private var locationManager: LocationManager

    private var saved: [CampusEvent] {
        store.savedEvents(userLocation: locationManager.location)
    }

    var body: some View {
        NavigationStack {
            Group {
                if saved.isEmpty {
                    ContentUnavailableView(
                        "No saved events",
                        systemImage: "bookmark",
                        description: Text("Bookmark an event from its detail screen to see it here on this device.")
                    )
                } else {
                    List(saved) { event in
                        NavigationLink(value: event) {
                            EventCardView(event: event, meters: locationManager.distance(to: event))
                        }
                    }
                }
            }
            .navigationTitle("Saved")
            .navigationDestination(for: CampusEvent.self) { event in
                EventDetailView(event: event)
            }
        }
    }
}
