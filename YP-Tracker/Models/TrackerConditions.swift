import Foundation

struct TrackerConditions {
	var date: Date
	var searchText: String
	var filter: TrackerFilter
	var hasAnyTrackers: Bool

	var dateString: String {
		Theme.dateFormatterShortYear.string(from: date)
	}
}
