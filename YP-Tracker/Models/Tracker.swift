import Foundation

struct Tracker: Identifiable, Hashable {
	let id: UUID
	let title: String
	let emoji: String
	let color: String
	let schedule: [Int: Bool]
	let pinned: Bool

	var scheduleString: String {
		let allSelectedDays = schedule.filter { $0.value }
		if allSelectedDays.count == 7 {
			return Theme.Texts.ScheduleNames.everyDay
		} else {
			return allSelectedDays
				.sorted { $0.key < $1.key }
			// в приложении дни недели 1..7 в календаре 0..6
				.map { Calendar.current.shortWeekdaySymbols[$0.key - 1] }
				.joined(separator: ", ")
		}
	}

	var scheduleCD: String {
		return schedule
			.sorted { $0.key < $1.key }
			.map { key, value -> String in value ? "\(key)" : "0" }
			.joined(separator: ",")
	}

	static func makeWeekDays() -> [String] {
		let calendar = Calendar.current
		let numDays: Int = calendar.weekdaySymbols.count
		let first: Int = calendar.firstWeekday - 1
		let end: Int = first + numDays - 1

		return (first...end).map { calendar.weekdaySymbols[$0 % numDays].localizedCapitalized }
	}
}

extension Tracker {
	enum TrackerType: CustomStringConvertible {
		case habit
		case event

		var description: String {
			switch self {
			case .habit:
				return TrackerNames.habit
			case .event:
				return TrackerNames.event
			}
		}
	}
	enum Action {
		case edit(UUID)
		case new(TrackerType)
		case selectCategory(UUID?)
		case selectSchedule([Int: Bool])
		case selectFilter(TrackerFilter)
		case addCategory
		case editCategory(UUID)
	}
}
