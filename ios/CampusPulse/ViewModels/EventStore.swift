import CoreLocation
import Foundation
import SwiftUI

@MainActor
final class EventStore: ObservableObject {
    @Published var events: [CampusEvent] = []
    @Published var filters = EventFilters()
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var savedIDs: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(savedIDs), forKey: Self.savedKey)
        }
    }

    private let api: APIService
    private static let savedKey = "savedEventIDs"

    init(api: APIService = APIService()) {
        self.api = api
        let saved = UserDefaults.standard.stringArray(forKey: Self.savedKey) ?? []
        savedIDs = Set(saved)
    }

    func visibleEvents(userLocation: CLLocation?) -> [CampusEvent] {
        filters.apply(events, userLocation: userLocation)
    }

    func savedEvents(userLocation: CLLocation?) -> [CampusEvent] {
        events.filter { savedIDs.contains($0.id) }
    }

    func toggleSaved(_ event: CampusEvent) {
        if savedIDs.contains(event.id) {
            savedIDs.remove(event.id)
        } else {
            savedIDs.insert(event.id)
        }
    }

    func refresh(userCoordinate: CLLocationCoordinate2D?) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            events = try await api.fetchEvents(
                category: filters.category,
                accessType: filters.access,
                latitude: userCoordinate?.latitude,
                longitude: userCoordinate?.longitude
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func create(_ draft: EventDraft) async throws -> CampusEvent {
        let created = try await api.createEvent(draft)
        events.insert(created, at: 0)
        await api.logActivity(eventType: "event_created", eventId: created.id)
        return created
    }

    func log(_ eventType: String, eventId: String? = nil, extra: [String: String] = [:]) {
        Task {
            await api.logActivity(eventType: eventType, eventId: eventId, extra: extra)
        }
    }
}
