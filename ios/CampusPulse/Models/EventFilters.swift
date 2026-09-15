import CoreLocation
import Foundation

enum TimeFilter: String, CaseIterable, Identifiable {
    case happeningNow
    case nextHour
    case today
    case tomorrow
    case thisWeek
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .happeningNow: "Happening now"
        case .nextHour: "Next hour"
        case .today: "Today"
        case .tomorrow: "Tomorrow"
        case .thisWeek: "This week"
        case .all: "All"
        }
    }
}

enum DistanceFilter: String, CaseIterable, Identifiable {
    case underQuarter
    case underHalf
    case underMile
    case campus

    var id: String { rawValue }

    var title: String {
        switch self {
        case .underQuarter: "Under 0.25 mi"
        case .underHalf: "Under 0.5 mi"
        case .underMile: "Under 1 mi"
        case .campus: "Anywhere on campus"
        }
    }

    var maxMiles: Double? {
        switch self {
        case .underQuarter: 0.25
        case .underHalf: 0.5
        case .underMile: 1
        case .campus: nil
        }
    }
}

enum EventSort: String, CaseIterable, Identifiable {
    case closest
    case soonest
    case newest

    var id: String { rawValue }

    var title: String {
        switch self {
        case .closest: "Closest"
        case .soonest: "Soonest"
        case .newest: "Newest"
        }
    }
}

struct EventFilters {
    var time: TimeFilter = .all
    var distance: DistanceFilter = .campus
    var category: EventCategory?
    var access: AccessType?
    var sort: EventSort = .soonest

    func apply(_ events: [CampusEvent], userLocation: CLLocation?, now: Date = .now) -> [CampusEvent] {
        let calendar = Calendar.current
        var result = events.filter { event in
            if let category, event.category != category { return false }
            if let access, event.accessType != access { return false }
            if !matchesTime(event, now: now, calendar: calendar) { return false }
            if let maxMiles = distance.maxMiles, let userLocation {
                let miles = userLocation.distance(
                    from: CLLocation(latitude: event.latitude, longitude: event.longitude)
                ) / 1609.344
                if miles > maxMiles { return false }
            }
            return true
        }

        switch sort {
        case .soonest:
            result.sort { $0.startsAt < $1.startsAt }
        case .newest:
            result.sort { $0.createdAt > $1.createdAt }
        case .closest:
            if let userLocation {
                result.sort {
                    userLocation.distance(from: CLLocation(latitude: $0.latitude, longitude: $0.longitude))
                        < userLocation.distance(from: CLLocation(latitude: $1.latitude, longitude: $1.longitude))
                }
            } else {
                result.sort { $0.startsAt < $1.startsAt }
            }
        }
        return result
    }

    private func matchesTime(_ event: CampusEvent, now: Date, calendar: Calendar) -> Bool {
        switch time {
        case .all:
            true
        case .happeningNow:
            event.startsAt <= now && now < event.endsAt
        case .nextHour:
            event.startsAt >= now && event.startsAt <= now.addingTimeInterval(3600)
        case .today:
            calendar.isDate(event.startsAt, inSameDayAs: now) || (event.startsAt <= now && now < event.endsAt)
        case .tomorrow:
            calendar.isDate(event.startsAt, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: now) ?? now)
        case .thisWeek:
            event.startsAt <= (calendar.date(byAdding: .day, value: 7, to: now) ?? now)
        }
    }
}
