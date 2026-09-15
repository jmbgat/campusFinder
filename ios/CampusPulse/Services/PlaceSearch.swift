import CoreLocation
import Foundation
import MapKit

/// Apple MapKit local search (no Google API key, no extra account).
@MainActor
final class PlaceSearch: ObservableObject {
    @Published var query = ""
    @Published var results: [MKMapItem] = []
    @Published var isSearching = false

    private var searchTask: Task<Void, Never>?

    func scheduleSearch(around center: CLLocationCoordinate2D) {
        searchTask?.cancel()
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.count >= 2 else {
            results = []
            return
        }
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            await search(text: text, around: center)
        }
    }

    func search(text: String, around center: CLLocationCoordinate2D) async {
        isSearching = true
        defer { isSearching = false }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.resultTypes = [.pointOfInterest, .address]
        request.region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
        do {
            let response = try await MKLocalSearch(request: request).start()
            results = response.mapItems
        } catch {
            results = []
        }
    }

    static func reverseGeocode(_ coordinate: CLLocationCoordinate2D) async -> String? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        guard let placemark = try? await CLGeocoder().reverseGeocodeLocation(location).first else {
            return nil
        }
        return placemark.name
            ?? placemark.areasOfInterest?.first
            ?? [placemark.subThoroughfare, placemark.thoroughfare]
                .compactMap { $0 }
                .joined(separator: " ")
                .nilIfEmpty
            ?? placemark.locality
    }
}

extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
