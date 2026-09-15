import CoreLocation
import Foundation

struct CampusEvent: Identifiable, Codable, Hashable {
    let id: String
    var title: String
    var description: String?
    var category: EventCategory
    var latitude: Double
    var longitude: Double
    var locationName: String
    var room: String?
    var floor: String?
    var locationDetails: String?
    var startsAt: Date
    var endsAt: Date
    var accessType: AccessType
    var createdAt: Date
    var updatedAt: Date
    var status: EventStatus
    var distanceMiles: Double?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var placeLine: String {
        var parts = [locationName]
        if let floor, !floor.isEmpty { parts.append(floor) }
        if let room, !room.isEmpty { parts.append("Room \(room)") }
        return parts.joined(separator: " · ")
    }

    func status(at now: Date = .now) -> EventStatus {
        if now < startsAt { return .upcoming }
        if now < endsAt { return .happeningNow }
        return .ended
    }
}

struct EventDraft: Encodable {
    var title: String
    var description: String?
    var category: EventCategory
    var latitude: Double
    var longitude: Double
    var locationName: String
    var room: String?
    var floor: String?
    var locationDetails: String?
    var startsAt: Date
    var endsAt: Date
    var accessType: AccessType
}
