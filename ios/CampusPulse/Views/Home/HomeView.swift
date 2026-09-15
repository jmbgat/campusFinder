import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: EventStore
    @EnvironmentObject private var locationManager: LocationManager
    @State private var showFilters = false

    private var visible: [CampusEvent] {
        store.visibleEvents(userLocation: locationManager.location)
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.isLoading && store.events.isEmpty {
                    ProgressView("Loading events…")
                } else if let message = store.errorMessage, store.events.isEmpty {
                    ContentUnavailableView {
                        Label("Unable to load events", systemImage: "wifi.slash")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Try again") { Task { await refresh() } }
                    }
                } else if visible.isEmpty {
                    ContentUnavailableView(
                        "No events match these filters.",
                        systemImage: "line.3.horizontal.decrease.circle",
                        description: Text("Try a wider time or distance filter, or post something happening nearby.")
                    )
                } else {
                    List(visible) { event in
                        NavigationLink(value: event) {
                            EventCardView(event: event, meters: locationManager.distance(to: event))
                        }
                    }
                    .listStyle(.plain)
                    .refreshable { await refresh() }
                }
            }
            .navigationTitle("CampusPulse")
            .navigationDestination(for: CampusEvent.self) { event in
                EventDetailView(event: event)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilters = true
                    } label: {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterSheet()
            }
            .overlay(alignment: .bottom) {
                if let denied = locationManager.deniedMessage {
                    Text(denied)
                        .font(.footnote)
                        .padding(10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding()
                }
            }
        }
    }

    private func refresh() async {
        await store.refresh(userCoordinate: locationManager.coordinate)
    }
}
