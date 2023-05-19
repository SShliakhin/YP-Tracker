import Foundation

protocol ITrackersInteractor {
	func viewIsReady()
	func didTypeNewSearchText(text: String)
	func didSelectNewDate(date: Date)
	func didCompleteUncompleteTracker(section: Int, row: Int)
}

final class TrackersInteractor: ITrackersInteractor {
	private let categoriesProvider: ICategoriesProvider
	private let presenter: ITrackersPresenter

	private var conditions: TrackersModels.Conditions?

	typealias SectionWithTrackers = TrackersModels.Response.SectionWithTrackers

	init(
		presenter: ITrackersPresenter,
		dep: ITrackersModuleDependency,
		conditions: TrackersModels.Conditions? = nil
	) {
		self.presenter = presenter
		categoriesProvider = dep.categoriesProvider
	}

	func didCompleteUncompleteTracker(section: Int, row: Int) {
		guard let conditions = conditions else {
			return
		}

		if categoriesProvider.completeUncompleteTrackerByPlace(
			section: section,
			row: row,
			date: conditions.date
		) { updateTrackers() }
	}

	func didTypeNewSearchText(text: String) {
		if conditions == nil {
			conditions = TrackersModels.Conditions(
				date: Date(),
				searchText: text,
				filter: TrackerFilter.all,
				hasAnyTrackers: categoriesProvider.hasAnyTrakers
			)
		} else {
			conditions?.searchText = text
		}

		updateTrackers()
	}

	func didSelectNewDate(date: Date) {
		if conditions == nil {
			conditions = TrackersModels.Conditions(
				date: date,
				searchText: "",
				filter: TrackerFilter.all,
				hasAnyTrackers: categoriesProvider.hasAnyTrakers
			)
		} else {
			conditions?.date = date
			// странный фильтр .today, если можем менять дату, то значит меняем и фильтр
			if conditions?.filter == .today {
				conditions?.filter = .all
			}
		}

		updateTrackers()
	}

	func viewIsReady() {
		if conditions == nil {
			conditions = TrackersModels.Conditions(
				date: Date(),
				searchText: "",
				filter: TrackerFilter.all,
				hasAnyTrackers: categoriesProvider.hasAnyTrakers
			)
		}

		updateTrackers()
	}

	private func updateTrackers() {
		guard let conditions = conditions else { return }

		let categories: [TrackerCategory]

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
		case .umcompleted:
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
