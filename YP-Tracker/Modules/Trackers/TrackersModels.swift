import Foundation

enum TrackersModels {

	struct Conditions {
		var date: Date
		var searchText: String
		var filter: TrackerFilter
		var hasAnyTrackers: Bool
	}

	enum Request {
		case update(Conditions)
		case changeFilter
		case completeUncompleTracker(Int, Int)
	}

	enum Response {
		struct SectionWithTrackers {
			let sectionName: String
			// swiftlint:disable:next large_tuple
			let trackers: [(tracker: Tracker, completed: Bool, allTimes: Int)]
		}
		case update([SectionWithTrackers], Conditions)
		case updateTracker(Int, Int)
	}

	enum ViewModel {
		struct TrackerModel {
			let colorString: String
			let emoji: String
			let title: String
			let dayTime: String
			let isCompleted: Bool
		}
		struct Section {
			let title: String
			let trackers: [TrackerModel]
		}

		case update([Section], Conditions)
		case updateTracker(Int, Int, TrackerModel)
	}
}
