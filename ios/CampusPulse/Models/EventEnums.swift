import Foundation
import SwiftUI

enum EventCategory: String, Codable, CaseIterable, Identifiable {
    case event
    case sports
    case giveaway
    case club
    case career
    case social
    case academic
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .event: "Events"
        case .sports: "Sports"
        case .giveaway: "Giveaways / Free Stuff"
        case .club: "Clubs"
        case .career: "Career / Networking"
        case .social: "Social / Entertainment"
        case .academic: "Academic / Study"
        case .other: "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .event: "star.fill"
        case .sports: "figure.basketball"
        case .giveaway: "gift.fill"
        case .club: "person.3.fill"
        case .career: "briefcase.fill"
        case .social: "music.mic"
        case .academic: "book.fill"
        case .other: "ellipsis.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .event: .indigo
        case .sports: .orange
        case .giveaway: .pink
        case .club: .teal
        case .career: .blue
        case .social: .purple
        case .academic: .green
        case .other: .gray
        }
    }
}

enum AccessType: String, Codable, CaseIterable, Identifiable {
    case open
    case registrationRequired
    case membersOnly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .open: "Open to everyone"
        case .registrationRequired: "Registration required"
        case .membersOnly: "Members / invite only"
        }
    }
}

enum EventStatus: String, Codable {
    case upcoming
    case happeningNow
    case ended

    var title: String {
        switch self {
        case .upcoming: "Upcoming"
        case .happeningNow: "Happening now"
        case .ended: "Ended"
        }
    }
}
