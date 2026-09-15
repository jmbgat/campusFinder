import CoreLocation
import MapKit
import SwiftUI

struct CreateEventView: View {
    @EnvironmentObject private var store: EventStore
    @EnvironmentObject private var locationManager: LocationManager
    @StateObject private var placeSearch = PlaceSearch()

    @State private var title = ""
    @State private var category: EventCategory = .event
    @State private var descriptionText = ""
    @State private var happeningNow = true
    @State private var startsAt = Date()
    @State private var endsAt = Date().addingTimeInterval(60 * 60)
    @State private var locationName = ""
    @State private var room = ""
    @State private var floor = ""
    @State private var locationDetails = ""
    @State private var accessType: AccessType = .open
    @State private var selectedLandmark: CampusLandmark?
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var pinSource = "None yet"
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var postedTitle: String?
    @State private var showMapPicker = false

    private var searchCenter: CLLocationCoordinate2D {
        if let latitude, let longitude {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return locationManager.coordinate ?? CampusLandmarks.fallbackRegionCenter
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("What") {
                    TextField("Title", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(EventCategory.allCases) { item in
                            Text(item.title).tag(item)
                        }
                    }
                    TextField("Description", text: $descriptionText, axis: .vertical)
                        .lineLimit(3 ... 6)
                }

                Section("When") {
                    Toggle("Happening now", isOn: $happeningNow)
                    if !happeningNow {
                        DatePicker("Starts", selection: $startsAt)
                    }
                    DatePicker("Ends", selection: $endsAt)
                }

                Section("Human-readable location") {
                    TextField("Building / place (e.g. CULC)", text: $locationName)
                    TextField("Room (e.g. 144)", text: $room)
                    TextField("Floor (e.g. 1st floor)", text: $floor)
                    TextField("Extra directions", text: $locationDetails, axis: .vertical)
                        .lineLimit(2 ... 4)
                }

                Section("Map pin") {
                    Text("Pin source: \(pinSource)")
                        .foregroundStyle(.secondary)

                    TextField("Search Apple Maps", text: $placeSearch.query)
                        .textInputAutocapitalization(.words)
                        .onChange(of: placeSearch.query) { _, _ in
                            placeSearch.scheduleSearch(around: searchCenter)
                        }

                    if placeSearch.isSearching {
                        ProgressView()
                    }

                    ForEach(placeSearch.results, id: \.self) { item in
                        Button {
                            applyMapItem(item)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(item.name ?? "Place")
                                    .foregroundStyle(.primary)
                                Text(item.placemark.title ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Button("Set pin on map") {
                        showMapPicker = true
                    }

                    Picker("Campus place", selection: $selectedLandmark) {
                        Text("Choose a listed building").tag(Optional<CampusLandmark>.none)
                        ForEach(CampusLandmarks.all) { landmark in
                            Text(landmark.name).tag(Optional(landmark))
                        }
                    }
                    .onChange(of: selectedLandmark) { _, landmark in
                        guard let landmark else { return }
                        applyCoordinate(
                            landmark.coordinate,
                            name: landmark.name,
                            source: "\(landmark.name) (listed campus coordinate)"
                        )
                    }

                    Button("Use Current Location") {
                        locationManager.requestWhenNeeded()
                        if let coordinate = locationManager.coordinate {
                            applyCoordinate(coordinate, name: nil, source: "Current GPS")
                        } else {
                            errorMessage = "Location is not available. Search Apple Maps, drop a pin, or pick a campus place."
                        }
                    }

                    Text("Search uses Apple Maps. Room and floor still need to be typed — the pin only gets you to the building.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Access") {
                    Picker("Who can come", selection: $accessType) {
                        ForEach(AccessType.allCases) { item in
                            Text(item.title).tag(item)
                        }
                    }
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        Task { await submit() }
                    } label: {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Post event")
                        }
                    }
                    .disabled(isSubmitting)
                }
            }
            .navigationTitle("Post")
            .sheet(isPresented: $showMapPicker) {
                MapPinPickerView(initialCoordinate: searchCenter) { coordinate, name in
                    applyCoordinate(coordinate, name: name, source: "Dropped pin on map")
                }
                .environmentObject(locationManager)
            }
            .alert("Posted", isPresented: Binding(
                get: { postedTitle != nil },
                set: { if !$0 { postedTitle = nil } }
            )) {
                Button("OK", role: .cancel) { resetForm() }
            } message: {
                Text("\(postedTitle ?? "Event") is on the backend. Pull to refresh Home or Map to see it.")
            }
        }
    }

    private func applyMapItem(_ item: MKMapItem) {
        applyCoordinate(
            item.placemark.coordinate,
            name: item.name,
            source: "Apple Maps search"
        )
        placeSearch.query = ""
        placeSearch.results = []
    }

    private func applyCoordinate(_ coordinate: CLLocationCoordinate2D, name: String?, source: String) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        pinSource = source
        errorMessage = nil
        if locationName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, let name, !name.isEmpty {
            locationName = name
        }
    }

    private func submit() async {
        errorMessage = nil
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPlace = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
        let start = happeningNow ? Date() : startsAt

        guard !trimmedTitle.isEmpty else {
            errorMessage = "Add a title."
            return
        }
        guard !trimmedPlace.isEmpty else {
            errorMessage = "Add a building or place name."
            return
        }
        guard endsAt > start else {
            errorMessage = "End time must be after start time."
            return
        }
        guard let latitude, let longitude else {
            errorMessage = "Search a place, set a pin on the map, pick a campus building, or use current location."
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        let draft = EventDraft(
            title: trimmedTitle,
            description: descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            category: category,
            latitude: latitude,
            longitude: longitude,
            locationName: trimmedPlace,
            room: room.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            floor: floor.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            locationDetails: locationDetails.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            startsAt: start,
            endsAt: endsAt,
            accessType: accessType
        )

        do {
            let created = try await store.create(draft)
            postedTitle = created.title
            await store.refresh(userCoordinate: locationManager.coordinate)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func resetForm() {
        title = ""
        descriptionText = ""
        happeningNow = true
        startsAt = Date()
        endsAt = Date().addingTimeInterval(3600)
        locationName = ""
        room = ""
        floor = ""
        locationDetails = ""
        selectedLandmark = nil
        latitude = nil
        longitude = nil
        pinSource = "None yet"
        postedTitle = nil
        placeSearch.query = ""
        placeSearch.results = []
    }
}
