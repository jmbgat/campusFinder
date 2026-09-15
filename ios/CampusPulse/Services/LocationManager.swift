import CoreLocation
import Foundation

@MainActor
final class LocationManager: NSObject, ObservableObject {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var coordinate: CLLocationCoordinate2D?
    @Published private(set) var location: CLLocation?
    @Published var deniedMessage: String?

    private let manager = CLLocationManager()

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = 50
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    func requestWhenNeeded() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            deniedMessage = nil
        case .denied, .restricted:
            deniedMessage = "Location is off. Distances are hidden, but you can still browse and post events."
        @unknown default:
            break
        }
    }

    func distance(to event: CampusEvent) -> CLLocationDistance? {
        guard let location else { return nil }
        return location.distance(from: CLLocation(latitude: event.latitude, longitude: event.longitude))
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            requestWhenNeeded()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        Task { @MainActor in
            location = latest
            coordinate = latest.coordinate
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            if coordinate == nil {
                deniedMessage = "Location is unavailable right now. Distances may be hidden."
            }
        }
    }
}
