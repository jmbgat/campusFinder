import SwiftUI

struct FilterSheet: View {
    @EnvironmentObject private var store: EventStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Picker("Time", selection: $store.filters.time) {
                    ForEach(TimeFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                Picker("Distance", selection: $store.filters.distance) {
                    ForEach(DistanceFilter.allCases) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                Picker("Category", selection: $store.filters.category) {
                    Text("Any").tag(Optional<EventCategory>.none)
                    ForEach(EventCategory.allCases) { category in
                        Text(category.title).tag(Optional(category))
                    }
                }
                Picker("Access", selection: $store.filters.access) {
                    Text("Any").tag(Optional<AccessType>.none)
                    ForEach(AccessType.allCases) { access in
                        Text(access.title).tag(Optional(access))
                    }
                }
                Picker("Sort", selection: $store.filters.sort) {
                    ForEach(EventSort.allCases) { sort in
                        Text(sort.title).tag(sort)
                    }
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        store.log("filter_changed", extra: ["sort": store.filters.sort.rawValue])
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
