import MapKit
import SwiftUI

/// Pan the map so the center pin sits on the place. Confirm saves that coordinate.
struct MapPinPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var locationManager: LocationManager

    var initialCoordinate: CLLocationCoordinate2D
    var onConfirm: (CLLocationCoordinate2D, String?) -> Void

    @State private var position: MapCameraPosition
    @State private var center: CLLocationCoordinate2D
    @State private var isGeocoding = false

    init(
        initialCoordinate: CLLocationCoordinate2D,
        onConfirm: @escaping (CLLocationCoordinate2D, String?) -> Void
    ) {
        self.initialCoordinate = initialCoordinate
        self.onConfirm = onConfirm
        _center = State(initialValue: initialCoordinate)
        _position = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: initialCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
                )
            )
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $position)
                    .mapControls {
                        MapUserLocationButton()
                        MapCompass()
                    }
                    .onMapCameraChange(frequency: .continuous) { context in
                        center = context.camera.centerCoordinate
                    }

                VStack {
                    Spacer()
                    Image(systemName: "mappin")
                        .font(.largeTitle)
                        .foregroundStyle(.red)
                        .shadow(radius: 2)
                        .offset(y: -18)
                    Spacer()
                }
                .allowsHitTesting(false)
            }
            .navigationTitle("Set pin on map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Use this pin") {
                        Task { await confirm() }
                    }
                    .disabled(isGeocoding)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Text("Move the map until the pin is on the right spot. Room and floor still go in the form.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.bar)
            }
            .onAppear {
                locationManager.requestWhenNeeded()
            }
        }
    }

    private func confirm() async {
        isGeocoding = true
        defer { isGeocoding = false }
        let name = await PlaceSearch.reverseGeocode(center)
        onConfirm(center, name)
        dismiss()
    }
}
