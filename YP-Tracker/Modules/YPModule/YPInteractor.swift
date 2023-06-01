import Foundation

enum EventYP {
	case selectFilter(TrackerFilter)
	case selectSchedule([Int: Bool])
	case selectCategory(UUID)
}

protocol IYPInteractor: AnyObject {
	func viewIsReady()
	func didUserDo(request: YPModels.Request)

	var didSendEventClosure: ((EventYP) -> Void)? { get set }
}

final class YPInteractor: IYPInteractor {
	private let trackerAction: Tracker.Action
	private let presenter: IYPPresenter
	private let categoriesProvider: ICategoriesProvider

	var didSendEventClosure: ((EventYP) -> Void)?

	private var schedule: [Int: Bool] = [:]
	private var weekDays: [String] = []
	private var categories: [TrackerCategory] = []

	init(
		presenter: IYPPresenter,
		dep: IYPModuleDependency,
		trackerAction: Tracker.Action
	) {
		self.presenter = presenter
		self.trackerAction = trackerAction
		self.categoriesProvider = dep.categoriesProvider
	}

	func viewIsReady() {
		if case let .selectSchedule(schedule) = trackerAction {
			self.schedule = schedule
			self.weekDays = Tracker.makeWeekDays()
			presenter.present(data: .selectSchedule(schedule, weekDays))
		}
		if case let .selectFilter(filter) = trackerAction {
			presenter.present(data: .selectFilter(filter, TrackerFilter.allValues))
		}
		if case let .selectCategory(categoryID) = trackerAction {
			categories = categoriesProvider.getCategories()
			presenter.present(data: .selectCategory(categoryID, categories))
		}
	}

	func didUserDo(request: YPModels.Request) {
		switch request {
		case let .selectItemAtIndex(index):
			if case .selectSchedule = trackerAction {
				schedule[index + 1] = !(schedule[index + 1] ?? false)
				presenter.present(data: .selectSchedule(schedule, weekDays))
			}
			if case .selectFilter = trackerAction {
				let filter = TrackerFilter.allValues[index]
				presenter.present(data: .selectFilter(filter, TrackerFilter.allValues))
				didSendEventClosure?(.selectFilter(filter))
			}
			if case .selectCategory = trackerAction {
				let category = categories[index]
				presenter.present(data: .selectCategory(category.id, categories))
				didSendEventClosure?(.selectCategory(category.id))
			}
		case .tapActionButton:
			if case .selectSchedule = trackerAction {
				didSendEventClosure?(.selectSchedule(schedule))
			}
		}
	}
}
