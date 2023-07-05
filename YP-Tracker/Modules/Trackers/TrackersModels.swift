import Foundation

enum TrackersModels {
	enum Request {
		case newSearchText(String)
		case newDate(Date)
		case completeUncompleteTracker(Int, Int)
		case newFilter(TrackerFilter)
		case addTracker
		case editTracker(Int, Int)
		case selectFilter
	}

	enum Response {
		struct SectionWithTrackers {
			let sectionName: String
			// swiftlint:disable:next large_tuple
			let trackers: [(tracker: Tracker, completed: Bool, allTimes: Int)]
		}
		case update([SectionWithTrackers], TrackerConditions, ITrackersInteractor?)
	}

	enum ViewModel {
		struct Section {
			let header: HeaderSupplementaryViewModel
			let trackers: [TrackerCellModel]
		}

		case update([Section], TrackerConditions)
	}
}
