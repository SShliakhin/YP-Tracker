import Foundation

enum TrackersModels {
	enum Request {
		case newSearchText(String)
		case newDate(Date)
		case completeUncompleteTracker(Int, Int)
		case newFilter(TrackerFilter)
		case addTracker
		case selectFilter
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
