import MapKit
import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject private var store: EventStore
    @EnvironmentObject private var locationManager: LocationManager
    let event: CampusEvent

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                descriptionBlock
                timeBlock
                locationBlock
                mapPreview
            }
            .padding()
        }
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.toggleSaved(event)
                } label: {
                    Image(systemName: store.savedIDs.contains(event.id) ? "bookmark.fill" : "bookmark")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: shareText)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button("Get Directions") { openDirections() }
                .buttonStyle(.borderedProminent)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.bar)
        }
        .onAppear {
            store.log("event_viewed", eventId: event.id)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(event.category.title, systemImage: event.category.systemImage)
                .foregroundStyle(event.category.tint)
            Text(event.title)
                .font(.largeTitle.bold())
            Text(event.accessType.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(event.status().title)
                .font(.headline)
                .foregroundStyle(event.status() == .happeningNow ? .green : .primary)
        }
    }

    @ViewBuilder
    private var descriptionBlock: some View {
        if let description = event.description, !description.isEmpty {
            Text(description)
        }
    }

    private var timeBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            labeled("Starts", event.startsAt.formatted(date: .abbreviated, time: .shortened))
            labeled("Ends", event.endsAt.formatted(date: .abbreviated, time: .shortened))
            labeled("Posted", event.createdAt.formatted(date: .abbreviated, time: .shortened))
        }
    }

    private var locationBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            labeled("Place", event.locationName)
            if let room = event.room, !room.isEmpty { labeled("Room", room) }
            if let floor = event.floor, !floor.isEmpty { labeled("Floor", floor) }
            if let details = event.locationDetails, !details.isEmpty {
                labeled("Directions", details)
            }
            if let meters = locationManager.distance(to: event) {
                labeled("Distance", DistanceFormat.string(meters: meters))
            }
        }
    }

    private var mapPreview: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: event.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
        ))) {
            Marker(event.locationName, coordinate: event.coordinate)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .allowsHitTesting(false)
    }

    private func labeled(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title.uppercased())
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
        }
    }

    private var shareText: String {
        "\(event.title) at \(event.placeLine) — \(event.startsAt.formatted(date: .abbreviated, time: .shortened))"
    }

    private func openDirections() {
        let item = MKMapItem(placemark: MKPlacemark(coordinate: event.coordinate))
        item.name = event.locationName
        item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
}
