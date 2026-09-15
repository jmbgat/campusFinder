import MapKit
import SwiftUI

struct EventMapView: View {
    @EnvironmentObject private var store: EventStore
    @EnvironmentObject private var locationManager: LocationManager
    @State private var showFilters = false
    @State private var selectedEvents: [CampusEvent] = []
    @State private var previewEvent: CampusEvent?
    @State private var pagerID = ""

    private var visible: [CampusEvent] {
        store.visibleEvents(userLocation: locationManager.location)
    }

    private var mapCenter: CLLocationCoordinate2D {
        locationManager.coordinate ?? CampusLandmarks.fallbackRegionCenter
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ClusteredEventMap(
                    events: visible,
                    initialCenter: mapCenter,
                    onSelect: { events in
                        selectedEvents = events
                        pagerID = events.first?.id ?? ""
                        if let first = events.first {
                            store.log("map_pin_opened", eventId: first.id)
                        }
                    }
                )
                .ignoresSafeArea(edges: .bottom)

                if !selectedEvents.isEmpty {
                    clusterPager
                }
            }
            .navigationTitle("Map")
            .navigationDestination(item: $previewEvent) { event in
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
            .onAppear {
                locationManager.requestWhenNeeded()
            }
            .task {
                if store.events.isEmpty {
                    await store.refresh(userCoordinate: locationManager.coordinate)
                }
            }
        }
    }

    private var clusterPager: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(selectedEvents.count == 1 ? selectedEvents[0].title : "\(selectedEvents.count) events here")
                    .font(.headline)
                Spacer()
                Button {
                    selectedEvents = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Close")
            }

            if selectedEvents.count > 1 {
                Text("Swipe sideways to see each event.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            TabView(selection: $pagerID) {
                ForEach(selectedEvents) { event in
                    VStack(alignment: .leading, spacing: 8) {
                        EventCardView(event: event, meters: locationManager.distance(to: event))
                        Button("View Details") {
                            previewEvent = event
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal, 4)
                    .tag(event.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: selectedEvents.count > 1 ? .always : .never))
            .frame(height: selectedEvents.count > 1 ? 210 : 160)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}
