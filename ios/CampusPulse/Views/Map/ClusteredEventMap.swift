import MapKit
import SwiftUI

struct ClusteredEventMap: UIViewRepresentable {
    var events: [CampusEvent]
    var initialCenter: CLLocationCoordinate2D
    var onSelect: ([CampusEvent]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.register(EventMarkerView.self, forAnnotationViewWithReuseIdentifier: EventMarkerView.reuseID)
        mapView.register(EventClusterView.self, forAnnotationViewWithReuseIdentifier: EventClusterView.reuseID)
        mapView.region = MKCoordinateRegion(
            center: initialCenter,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        context.coordinator.mapView = mapView
        context.coordinator.sync(events: events)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.onSelect = onSelect
        context.coordinator.sync(events: events)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var onSelect: ([CampusEvent]) -> Void
        weak var mapView: MKMapView?

        init(onSelect: @escaping ([CampusEvent]) -> Void) {
            self.onSelect = onSelect
        }

        func sync(events: [CampusEvent]) {
            guard let mapView else { return }
            let incomingIDs = Set(events.map(\.id))
            let existing = mapView.annotations.compactMap { $0 as? EventAnnotation }

            for annotation in existing where !incomingIDs.contains(annotation.event.id) {
                mapView.removeAnnotation(annotation)
            }

            let remainingIDs = Set(mapView.annotations.compactMap { ($0 as? EventAnnotation)?.event.id })
            let toAdd = events.filter { !remainingIDs.contains($0.id) }.map(EventAnnotation.init)
            if !toAdd.isEmpty {
                mapView.addAnnotations(toAdd)
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            if annotation is MKClusterAnnotation {
                return mapView.dequeueReusableAnnotationView(
                    withIdentifier: EventClusterView.reuseID,
                    for: annotation
                )
            }
            return mapView.dequeueReusableAnnotationView(
                withIdentifier: EventMarkerView.reuseID,
                for: annotation
            )
        }

        func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
            MKClusterAnnotation(memberAnnotations: memberAnnotations)
        }

        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            mapView.deselectAnnotation(annotation, animated: false)
            let events: [CampusEvent]
            if let cluster = annotation as? MKClusterAnnotation {
                events = cluster.memberAnnotations.compactMap { ($0 as? EventAnnotation)?.event }
            } else if let pin = annotation as? EventAnnotation {
                events = [pin.event]
            } else {
                return
            }
            onSelect(events.sorted { $0.startsAt < $1.startsAt })
        }
    }
}
