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
                    Text(endLabel)
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

    private var endLabel: String {
        "Ends \(event.endsAt.formatted(date: .omitted, time: .shortened))"
    }
}
