import CoreLocation
import Foundation

enum DistanceFormat {
    static func string(meters: CLLocationDistance) -> String {
        if meters < 300 {
            let feet = meters * 3.28084
            return "\(Int(feet.rounded())) ft away"
        }
        let miles = meters / 1609.344
        if miles < 10 {
            return String(format: "%.1f mi away", miles)
        }
        return String(format: "%.0f mi away", miles)
    }

    static func string(miles: Double) -> String {
        string(meters: miles * 1609.344)
    }
}
