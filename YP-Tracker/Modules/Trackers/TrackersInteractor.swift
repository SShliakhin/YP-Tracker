import Foundation

enum EventTrackersInteractor {
	case addTracker
	case editTracker(UUID)
	case selectFilter(TrackerFilter)
}

protocol ITrackersInteractor: AnyObject {
	func viewIsReady()
	func didUserDo(request: TrackersModels.Request)

	var didSendEventClosure: ((EventTrackersInteractor) -> Void)? { get set }
}

final class TrackersInteractor: ITrackersInteractor {
	private let categoriesProvider: ICategoriesProvider
	private let presenter: ITrackersPresenter

	private var conditions: TrackerConditions
	var didSendEventClosure: ((EventTrackersInteractor) -> Void)?

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
			if conditions.filter == .today {
				conditions.filter = .all
			}
		case let .newFilter(filter):
			conditions.filter = filter
			if filter == .today {
				conditions.date = Date()
			}
		case let .completeUncompleteTracker(section, row):
			guard categoriesProvider.completeUncompleteTrackerByPlace(
				section: section,
				row: row,
				date: conditions.date
			) else { return }
		case let .editTracker(section, row):
			let trackerID = categoriesProvider.getTrackerID(
				section: section,
				row: row
			)
			didSendEventClosure?(.editTracker(trackerID))
			return
		case let .deleteTracker(section, row):
			categoriesProvider.removeTrackerByPlace(
				section: section,
				row: row
			)
		case let .pinUnpin(section, row):
			categoriesProvider.pinUnpinTrackerByPlace(
				section: section,
				row: row
			)
		case .addTracker:
			didSendEventClosure?(.addTracker)
			return
		case .selectFilter:
			didSendEventClosure?(.selectFilter(conditions.filter))
			return
		}
		updateTrackers()
	}
}

private extension TrackersInteractor {
	func updateTrackers() {
		let categories: [TrackerCategory]

		conditions.hasAnyTrackers = categoriesProvider.hasAnyTrakers

		switch conditions.filter {
		case .today, .all:
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

		presenter.present(data: .update(sectionsWithTrackers, conditions, self))
	}
}
