import Foundation

protocol ICategoriesProvider {
	func getCategoriesNames() -> [String]
	func getCategories(date: Date, text: String?, completed: Bool?) -> [TrackerCategory]
	// swiftlint:disable:next large_tuple
	func getTrackerBoxByID(_ id: UUID) -> (tracker: Tracker, completed: Bool, allTimes: Int)?
}

final class CategoriesProvider: ICategoriesProvider {
	private let categoriesManager: ICategoriesManager
	private let calendar = Calendar.current

	private var categories: [TrackerCategory] = []
	private var trackers: [Tracker] = []
	private var completedTrackers: [TrackerRecord] = []

	private var allTimesCompleted: [UUID: Int] = [:]

	init(
		categoriesManager: ICategoriesManager
	) {
		self.categoriesManager = categoriesManager
	}

	func getCategoriesNames() -> [String] {
		categoriesManager.getCategories().map { $0.title }
	}

	func getCategories(date: Date, text: String?, completed: Bool?) -> [TrackerCategory] {

		let filterWeekday = calendar.component(.weekday, from: date)
		let filterText = (text ?? "").lowercased()

		// фильтруем существующие трекеры по переданным дню и текстовому фильтру
		// - трекеры без расписание получаем с учетом только текстового фильтра
		// - трекеры с расписание отбираем по дню и текстовому фильтру
		trackers = categoriesManager.getTrackers().filter { tracker in
			let dateCondition = tracker.schedule.isEmpty || tracker.schedule[filterWeekday] ?? false
			let textCondition = filterText.isEmpty || tracker.title.lowercased().contains(filterText)
			return dateCondition && textCondition
		}

		// у отфильтрованных трекеров возьмем их id
		var trackersUUID = trackers.map { tracker in
			tracker.id
		}

		// получим список завершенных трекеров на переданную дату
		completedTrackers = categoriesManager.getCompletedTrackers().filter { record in
			let isTheSameDay = calendar.isDate(record.date, inSameDayAs: date)
			return trackersUUID.contains(record.trackerId) && isTheSameDay
		}

		// получим списко сколько раз каждый трекер был выполнен
		allTimesCompleted = categoriesManager.getCompletedTrackers().reduce(into: [:]) { times, record in
			times[record.trackerId, default: 0] += 1
		}

		// дополнительно отфильтруем по фильтру трекеров
		switch completed {
		case .none:
			break // здесь не фильтруем
		case let .some(completed):
			// нужно отфильтровать - получаем id завершенных трекеров
			let completedTrackersID = completedTrackers.map { record in
				record.trackerId
			}
			if completed {
				// оставляем только завершенные
				trackersUUID = trackersUUID.filter { completedTrackersID.contains($0) }
			} else {
				// оставляем только незавершенные
				trackersUUID = trackersUUID.filter { !completedTrackersID.contains($0) }
			}
		}

		// создаем категории которые содержат только отфильтрованные трекеры
		categories = categoriesManager.getCategories().compactMap { category in
			let trackers = category.trackers.filter { id in
				trackersUUID.contains(id)
			}

			if trackers.isEmpty { return nil }

			return TrackerCategory(
				id: category.id,
				title: category.title,
				trackers: trackers
			)
		}
		categories = categories.sorted { $0.title < $1.title }

		return categories
	}

	// swiftlint:disable:next large_tuple
	func getTrackerBoxByID(_ id: UUID) -> (tracker: Tracker, completed: Bool, allTimes: Int)? {
		guard let tracker = trackers.first(where: { $0.id == id }) else { return nil }
		return (
			tracker,
			completedTrackers.contains(where: { $0.trackerId == id }),
			allTimesCompleted[tracker.id] ?? 0
		)
	}
}
