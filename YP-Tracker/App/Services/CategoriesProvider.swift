import Foundation

protocol ICategoriesProvider {
	func getCategoriesNames() -> [String]
	func getCategories(date: Date, text: String?, completed: Bool?) -> [TrackerCategory]
	func getTrackerBoxByID(_ id: UUID) -> (tracker: Tracker, completed: Bool)?
}

final class CategoriesProvider: ICategoriesProvider {
	private let categoriesManager: ICategoriesManager
	private let calendar = Calendar.current

	private var categories: [TrackerCategory] = []
	private var trackers: [Tracker] = []
	private var completedTrackers: [TrackerRecord] = []

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

		trackers = categoriesManager.getTrackers().filter { tracker in
			let dateCondition = tracker.schedule.isEmpty || tracker.schedule[filterWeekday] ?? false
			let textCondition = filterText.isEmpty || tracker.title.lowercased().contains(filterText)
			return dateCondition && textCondition
		}

		var trackersUUID = trackers.map { tracker in
			tracker.id
		}

		completedTrackers = categoriesManager.getCompletedTrackers().filter { record in
			let isTheSameDay = calendar.isDate(record.date, inSameDayAs: date)
			return trackersUUID.contains(record.trackerId) && isTheSameDay
		}

		switch completed {
		case .none:
			break
		case let .some(completed):
			let completedTrackersID = completedTrackers.map { record in
				record.trackerId
			}
			if completed {
				trackersUUID = trackersUUID.filter { completedTrackersID.contains($0) }
			} else {
				trackersUUID = trackersUUID.filter { !completedTrackersID.contains($0) }
			}
		}

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

	func getTrackerBoxByID(_ id: UUID) -> (tracker: Tracker, completed: Bool)? {
		guard let tracker = trackers.first(where: { $0.id == id }) else { return nil }
		return (tracker, completedTrackers.contains(where: { $0.trackerId == id }))
	}
}
