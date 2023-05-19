import Foundation

protocol ITrackersInteractor {
	func viewIsReady()
}

typealias SectionWithTrackers = TrackersModels.Response.SectionWithTrackers

final class TrackersInteractor: ITrackersInteractor {
	private let categoriesProvider: ICategoriesProvider
	private let presenter: ITrackersPresenter

	private var conditions: TrackersModels.Conditions?

	init(
		presenter: ITrackersPresenter,
		dep: ITrackersModuleDependency,
		conditions: TrackersModels.Conditions? = nil
	) {
		self.presenter = presenter
		categoriesProvider = dep.categoriesProvider
	}

	func viewIsReady() {
		guard let conditions = conditions else {
			conditions = TrackersModels.Conditions(
				date: Date(),
				searchText: "",
				filter: TrackerFilter.today
			)
			return viewIsReady()
		}

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

		presenter.present(data: .update(sectionsWithTrackers))
	}
}
