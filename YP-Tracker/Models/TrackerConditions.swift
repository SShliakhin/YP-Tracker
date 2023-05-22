import Foundation

struct TrackerConditions: Equatable {
	var date: Date
	var searchText: String
	var filter: TrackerFilter
	var hasAnyTrackers: Bool

	static func ==(lhs: TrackerConditions, rhs: TrackerConditions) -> Bool {
		return Calendar.current.isDate(
			lhs.date,
			inSameDayAs: lhs.date
		) &&
		lhs.searchText == rhs.searchText &&
		lhs.filter == rhs.filter &&
		lhs.hasAnyTrackers == rhs.hasAnyTrackers
	}
}
