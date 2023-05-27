import Foundation

struct Tracker: Identifiable, Hashable {
	let id: UUID
	let title: String
	let emoji: String
	let color: String
	let schedule: [Int: Bool]

	var scheduleString: String {
		schedule
			.filter { $0.value }
			.sorted { $0.key < $1.key }
			.map { Calendar.current.shortWeekdaySymbols[$0.key] }
			.joined(separator: ",")
	}
}

extension Tracker {
	enum TrackerType {
		case habit
		case event
	}
	enum Action {
		case edit(UUID) // редактировать существующий трекер -> TrackerTempData/save/cancel
		case new([Int: Bool]) // создать новый трекер, передаем расписание -> TrackerTempData/save/cancel
		case selectCategory(UUID?) // передаем существующие UUID категории -> UUID
		case selectSchedule([Int: Bool]) // передаем существующее расписание -> Set<WeekDay>
		case save // преобразуем TrackerTempData в трекер с новым/старым UUID
		case cancel
		// продолжить редактирование нового/существующего(UUID) -> TrackerTempData/save/cancel
		// case reedit(TrackerTempData, UUID?)
		case selectFilter(TrackerFilter)
	}
}
