import Foundation

protocol ITrackersInteractor {
	func viewIsReady()
	func updateConditions(newConditions: TrackerConditions)
	func didTypeNewSearchText(text: String)
	func didSelectNewDate(date: Date)
	func didCompleteUncompleteTracker(section: Int, row: Int)
	func getConditions() -> TrackerConditions
}

final class TrackersInteractor: ITrackersInteractor {
	private let categoriesProvider: ICategoriesProvider
	private let presenter: ITrackersPresenter

	private var conditions: TrackerConditions

	typealias SectionWithTrackers = TrackersModels.Response.SectionWithTrackers

	init(
		presenter: ITrackersPresenter,
		dep: ITrackersModuleDependency
	) {
		self.presenter = presenter
		self.categoriesProvider = dep.categoriesProvider

		self.conditions = TrackerConditions(
			date: Date(),
			searchText: "",
			filter: .all,
			hasAnyTrackers: false
		)
	}

	func updateConditions(newConditions: TrackerConditions) {
		if conditions != newConditions {
			conditions = newConditions
			updateTrackers()
		}
	}

	func getConditions() -> TrackerConditions {
		conditions
	}

	func didCompleteUncompleteTracker(section: Int, row: Int) {
		if categoriesProvider.completeUncompleteTrackerByPlace(
			section: section,
			row: row,
			date: conditions.date
		) {
			updateTrackers()
		}
	}

	func didTypeNewSearchText(text: String) {
		conditions.searchText = text
		updateTrackers()
	}

	func didSelectNewDate(date: Date) {
		conditions.date = date
		// странный фильтр .today, если можем менять дату, то значит меняем и фильтр
		if conditions.filter == .today {
			conditions.filter = .all
		}
		updateTrackers()
	}

	func viewIsReady() {
		updateTrackers()
	}

	private func updateTrackers() {
		let categories: [TrackerCategory]

		conditions.hasAnyTrackers = categoriesProvider.hasAnyTrakers

		switch conditions.filter {
		case .today:
			categories = categoriesProvider.getCategories(
				date: Date(),
				text: conditions.searchText,
				completed: nil
			)
		case .all:
			categories = categoriesProvider.getCategories(
				date: conditions.date,
				text: conditions.searchText,
				completed: nil
			)
		case .completed:
			categories = categoriesProvider.getCategories(
				date: conditions.date,
				text: conditions.searchText,
				completed: true
			)
		case .uncompleted:
			categories = categoriesProvider.getCategories(
				date: conditions.date,
				text: conditions.searchText,
				completed: false
			)
		}

		var sectionsWithTrackers: [SectionWithTrackers] = []

		for category in categories {
			let sectionWithTrackers = SectionWithTrackers(
				sectionName: category.title,
				trackers: category.trackers.compactMap { categoriesProvider.getTrackerBoxByID($0) }
			)
			sectionsWithTrackers.append(sectionWithTrackers)
		}

		presenter.present(data: .update(sectionsWithTrackers, conditions))
	}
}
