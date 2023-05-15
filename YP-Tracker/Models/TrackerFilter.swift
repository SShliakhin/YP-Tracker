enum TrackerFilter {
	case today
	case all
	case completed
	case umcompleted
}

extension TrackerFilter: CustomStringConvertible {
	var description: String {
		switch self {
		case .today:
			return "Трекеры на сегодня"
		case .all:
			return "Все трекеры"
		case .completed:
			return "Завершенные"
		case .umcompleted:
			return "Не завершенные"
		}
	}
}
