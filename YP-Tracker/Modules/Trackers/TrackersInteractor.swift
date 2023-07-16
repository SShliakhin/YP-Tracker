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
	private let presenter: ITrackersPresenter

	private let categoriesProvider: ICategoriesProvider
	private let analyticsService: IAnalyticsService
	private let statisticsService: StatisticsIn

	private var conditions: TrackerConditions
	private var trackersCount = 0 // количество трекеров на выбранный день для статистики

	var didSendEventClosure: ((EventTrackersInteractor) -> Void)?

	typealias SectionWithTrackers = TrackersModels.Response.SectionWithTrackers

	init(
		presenter: ITrackersPresenter,
		dep: ITrackersModuleDependency
	) {
		self.presenter = presenter
		self.categoriesProvider = dep.categoriesProvider
		self.analyticsService = dep.analyticsService
		self.statisticsService = dep.statisticsIn

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

	// swiftlint:disable:next function_body_length
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

			// FIXME: - пока не совсем согласованные действия между CoreData и статистикой
			// приходится повторяться и помнить что работаем со старыми данными
			let trackerID = categoriesProvider.getTrackerID(section: section, row: row)
			guard let (_, completed, _) = categoriesProvider.getTrackerBoxByID(trackerID) else { return }

			if completed {
				// трекер был завершенный, значит отменяем
				statisticsService.uncompleteTracker(
					on: conditions.date
				)
			} else {
				// трекер был незавершенный, значит завершаем
				statisticsService.completeTracker(
					on: conditions.date,
					with: trackersCount
				)

				log(.click(.track))
			}

		case let .editTracker(section, row):
			let trackerID = categoriesProvider.getTrackerID(
				section: section,
				row: row
			)
			didSendEventClosure?(.editTracker(trackerID))

			log(.click(.edit))
			return
		case let .deleteTracker(section, row):
			categoriesProvider.removeTrackerByPlace(
				section: section,
				row: row
			)

			log(.click(.delete))
		case let .pinUnpin(section, row):
			categoriesProvider.pinUnpinTrackerByPlace(
				section: section,
				row: row
			)
		case .addTracker:
			didSendEventClosure?(.addTracker)

			log(.click(.addTrack))
			return
		case .selectFilter:
			didSendEventClosure?(.selectFilter(conditions.filter))

			log(.click(.filter))
			return
		case let .analyticsEvent(event):
			log(event)
			return
		}
		updateTrackers()
	}
}

private extension TrackersInteractor {
	func updateTrackers() {
		trackersCount = 0
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
			trackersCount += sectionWithTrackers.trackers.count
			sectionsWithTrackers.append(sectionWithTrackers)
		}

		presenter.present(data: .update(sectionsWithTrackers, conditions, self))
	}

	func log(_ type: AnalyticsEvent.EventType) {
		analyticsService.log(.init(type: type, screen: .main))
	}
}
