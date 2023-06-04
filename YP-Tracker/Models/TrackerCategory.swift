import Foundation

struct TrackerCategory: Identifiable, Hashable {
	let id: UUID
	let title: String
	let trackers: [UUID]

	init(id: UUID = UUID(), title: String, trackers: [UUID]) {
		self.id = id
		self.title = title
		self.trackers = trackers
	}
}
