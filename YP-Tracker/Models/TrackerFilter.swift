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
			return Appearance.all
		case .today:
			return Appearance.today
		case .completed:
			return Appearance.completed
		case .uncompleted:
			return Appearance.uncompleted
		}
	}
}

// MARK: - Appearance
private extension TrackerFilter {
	enum Appearance {
		static let all = NSLocalizedString(
			"tracker.filterAll.title",
			comment: "Название фильтра: Все"
		)
		static let today = NSLocalizedString(
			"tracker.filterToday.title",
			comment: "Название фильтра: Сегодня"
		)
		static let completed = NSLocalizedString(
			"tracker.filterCompleted.title",
			comment: "Название фильтра: Завершенные"
		)
		static let uncompleted = NSLocalizedString(
			"tracker.filterUncompleted.title",
			comment: "Название фильтра: Не завершенные"
		)
	}
}
