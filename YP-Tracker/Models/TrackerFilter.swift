import Foundation
enum TrackerFilter {
	case all
	case today
	case completed
	case uncompleted

	static var allValues: [TrackerFilter] {
		[.all, .today, .completed, .uncompleted]
	}
}

extension TrackerFilter: CustomStringConvertible {
	var description: String {
		switch self {
		case .all:
			return Theme.Texts.TrackerFilterNames.all
		case .today:
			return Theme.Texts.TrackerFilterNames.today
		case .completed:
			return Theme.Texts.TrackerFilterNames.completed
		case .uncompleted:
			return Theme.Texts.TrackerFilterNames.uncompleted
		}
	}
}
