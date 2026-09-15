import MapKit
import UIKit

final class EventAnnotation: NSObject, MKAnnotation {
    let event: CampusEvent
    dynamic var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(event: CampusEvent) {
        self.event = event
        self.coordinate = event.coordinate
        self.title = event.title
        self.subtitle = event.locationName
        super.init()
    }
}

final class EventMarkerView: MKMarkerAnnotationView {
    static let reuseID = "EventMarker"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        clusteringIdentifier = "campuspulse-events"
        displayPriority = .defaultHigh
        collisionMode = .circle
        canShowCallout = false
        applyStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var annotation: MKAnnotation? {
        didSet {
            clusteringIdentifier = "campuspulse-events"
            applyStyle()
        }
    }

    private func applyStyle() {
        guard let event = (annotation as? EventAnnotation)?.event else { return }
        glyphImage = UIImage(systemName: event.category.systemImage)
        markerTintColor = UIColor(event.status() == .happeningNow ? .green : event.category.tint)
    }
}

final class EventClusterView: MKMarkerAnnotationView {
    static let reuseID = "EventCluster"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .defaultHigh
        collisionMode = .circle
        canShowCallout = false
        applyStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var annotation: MKAnnotation? {
        didSet { applyStyle() }
    }

    private func applyStyle() {
        clusteringIdentifier = nil
        let count = (annotation as? MKClusterAnnotation)?.memberAnnotations.count ?? 0
        glyphText = "\(count)"
        markerTintColor = .systemIndigo
        glyphTintColor = .white
    }
}
