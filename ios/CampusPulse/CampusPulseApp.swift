import SwiftUI

@main
struct CampusPulseApp: App {
    @StateObject private var eventStore = EventStore()
    @StateObject private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(eventStore)
                .environmentObject(locationManager)
                .task {
                    locationManager.requestWhenNeeded()
                    eventStore.log("app_open")
                    await eventStore.refresh(userCoordinate: locationManager.coordinate)
                }
        }
    }
}
