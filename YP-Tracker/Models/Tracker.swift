import Foundation

struct Tracker: Identifiable, Hashable {
	let id: UUID
	let title: String
	let emoji: String
	let color: String
	let schedule: [Int: Bool]

	var scheduleString: String {
		let allSelectedDays = schedule.filter { $0.value }
		if allSelectedDays.count == 7 {
			return "Каждый день"
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
				return Appearance.habit
			case .event:
				return Appearance.event
			}
		}
	}
	enum Action {
		case edit(UUID) // редактировать существующий трекер -> TrackerTempData/save/cancel
		case new(TrackerType) // создать новый трекер, передаем тип -> TrackerTempData/save/cancel
		case selectCategory(UUID?) // передаем существующие UUID категории -> UUID
		case selectSchedule([Int: Bool]) // передаем существующее расписание -> Set<WeekDay>
		case save // преобразуем TrackerTempData в трекер с новым/старым UUID
		case cancel
		// продолжить редактирование нового/существующего(UUID) -> TrackerTempData/save/cancel
		// case reedit(TrackerTempData, UUID?)
		case selectFilter(TrackerFilter)
	}
}

// MARK: - Appearance
private extension Tracker {
	enum Appearance {
		static let habit = "Привычка"
		static let event = "Нерегулярное событие"
	}
}
