import SwiftUI

struct EventCardView: View {
    let event: CampusEvent
    var meters: Double?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: event.category.systemImage)
                .font(.title3)
                .foregroundStyle(event.category.tint)
                .frame(width: 36, height: 36)
                .background(event.category.tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(event.category.title.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(event.category.tint)
                Text(event.title)
                    .font(.headline)
                Text(event.placeLine)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack {
                    if let meters {
                        Text(DistanceFormat.string(meters: meters))
                    }
                    Text(event.status().title)
                    Text(timeLabel)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                if let description = event.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .lineLimit(2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    /// Upcoming events show when they start (the thing you need to plan around);
    /// events already happening show when they end.
    private var timeLabel: String {
        switch event.status() {
        case .upcoming:
            "Starts \(Self.shortTime(event.startsAt))"
        case .happeningNow:
            "Ends \(Self.shortTime(event.endsAt))"
        case .ended:
            "Ended \(Self.shortTime(event.endsAt))"
        }
    }

    /// "6:49 PM" today, otherwise "Wed 8:09 PM".
    private static func shortTime(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        }
        return date.formatted(.dateTime.weekday(.abbreviated).hour().minute())
    }
}
