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
			return "Все трекеры"
		case .today:
			return "Трекеры на сегодня"
		case .completed:
			return "Завершенные"
		case .uncompleted:
			return "Не завершенные"
		}
	}
}
