import Foundation

protocol ICategoriesProvider {
	var hasAnyTrakers: Bool { get }

	func getCategories() -> [TrackerCategory]
	func getCategories(date: Date, text: String?, completed: Bool?) -> [TrackerCategory]
	// swiftlint:disable:next large_tuple
	func getTrackerBoxByID(_ id: UUID) -> (tracker: Tracker, completed: Bool, allTimes: Int)?
	func completeUncompleteTrackerByPlace(section: Int, row: Int, date: Date) -> Bool
	func getTrackerID(section: Int, row: Int) -> UUID
}

final class CategoriesProvider: ICategoriesProvider {
	var hasAnyTrakers: Bool {
		!categoriesManager.getTrackers().isEmpty
	}

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

	func getCategories() -> [TrackerCategory] {
		categoriesManager.getCategories()
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

		// пока небольшая оптимизация - для CD этот модуль надо тоже переписать, особенно этот метод
		let allCompletedTrackers = categoriesManager.getCompletedTrackers()

		// получим список завершенных трекеров на переданную дату
		completedTrackers = allCompletedTrackers.filter { record in
			let isTheSameDay = calendar.isDate(record.date, inSameDayAs: date)
			return trackersUUID.contains(record.trackerId) && isTheSameDay
		}

		// получим список сколько раз каждый трекер был выполнен
		allTimesCompleted = allCompletedTrackers
			.reduce(into: [:]) { $0[$1.trackerId, default: 0] += 1 }

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

	func completeUncompleteTrackerByPlace(section: Int, row: Int, date: Date) -> Bool {
		let trackerID = getTrackerID(section: section, row: row)
		guard let (_, completed, _) = getTrackerBoxByID(trackerID) else { return false }

		if completed {
			categoriesManager.cancelCompletedTracker(
				trackerID: trackerID,
				date: date
			)
		} else {
			categoriesManager.addCompletedTracker(
				trackerID: trackerID,
				date: date
			)
		}
		return true
	}

	func getTrackerID(section: Int, row: Int) -> UUID {
		// не безопасно!!!
		categories[section].trackers[row]
	}
}
