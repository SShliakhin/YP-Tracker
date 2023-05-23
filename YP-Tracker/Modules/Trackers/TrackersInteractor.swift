import Foundation

protocol ITrackersInteractor {
	func viewIsReady()
	func didUserDo(request: TrackersModels.Request)
	func getConditions() -> TrackerConditions

	func updateConditions(newConditions: TrackerConditions)
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

	func viewIsReady() {
		updateTrackers()
	}

	func didUserDo(request: TrackersModels.Request) {
		switch request {
		case let .newSearchText(text):
			conditions.searchText = text
		case let .newDate(date):
			conditions.date = date
			// странный фильтр .today, если можем менять дату, то значит меняем и фильтр
			if conditions.filter == .today {
				conditions.filter = .all
			}
		case let .completeUncompleteTracker(section, row):
			guard categoriesProvider.completeUncompleteTrackerByPlace(
				section: section,
				row: row,
				date: conditions.date
			) else { return }
		}
		updateTrackers()
	}

	func getConditions() -> TrackerConditions {
		conditions
	}

	func updateConditions(newConditions: TrackerConditions) {
		if conditions != newConditions {
			conditions = newConditions
			updateTrackers()
		}
	}
}

private extension TrackersInteractor {
	func updateTrackers() {
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
