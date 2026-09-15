import CoreLocation
import Foundation

struct CampusLandmark: Identifiable, Hashable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum CampusLandmarks {
    /// Approximate Georgia Tech coordinates for assignment pins — verify before treating as official GIS.
    static let all: [CampusLandmark] = [
        .init(id: "culc", name: "CULC", latitude: 33.77462, longitude: -84.39632),
        .init(id: "crc", name: "CRC", latitude: 33.77547, longitude: -84.40355),
        .init(id: "klaus", name: "Klaus", latitude: 33.77715, longitude: -84.39584),
        .init(id: "vanleer", name: "Van Leer", latitude: 33.77592, longitude: -84.39708),
        .init(id: "techgreen", name: "Tech Green", latitude: 33.77473, longitude: -84.39728),
        .init(id: "studentcenter", name: "Student Center", latitude: 33.77379, longitude: -84.39875),
        .init(id: "library", name: "Price Gilbert Library", latitude: 33.77425, longitude: -84.39555),
    ]

    static let fallbackRegionCenter = CLLocationCoordinate2D(latitude: 33.77473, longitude: -84.39728)
}
