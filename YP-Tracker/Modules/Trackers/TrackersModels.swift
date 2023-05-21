import Foundation

enum TrackersModels {

//	struct Conditions {
//		var date: Date
//		var searchText: String
//		var filter: TrackerFilter
//		var hasAnyTrackers: Bool
//	}

	enum Request {
		case update(TrackerConditions)
		case changeFilter
		case completeUncompleTracker(Int, Int)
	}

	enum Response {
		struct SectionWithTrackers {
			let sectionName: String
			// swiftlint:disable:next large_tuple
			let trackers: [(tracker: Tracker, completed: Bool, allTimes: Int)]
		}
		case update([SectionWithTrackers], TrackerConditions)
	}

	enum ViewModel {
		struct TrackerModel {
			let colorString: String
			let emoji: String
			let title: String
			let dayTime: String
			let isCompleted: Bool
			let isActionEnabled: Bool
		}
		struct Section {
			let title: String
			let trackers: [TrackerModel]
		}

		case update([Section], TrackerConditions)
	}
}
