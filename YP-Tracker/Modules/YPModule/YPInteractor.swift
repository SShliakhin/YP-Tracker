import Foundation

protocol IYPInteractor {
	func viewIsReady(actions: ((YPViewController.Event) -> Void)?)
	func didSelectItem(_ index: Int)
	func didTapActionButton()
}

final class YPInteractor: IYPInteractor {
	private let trackerAction: Tracker.Action
	private let presenter: IYPPresenter
	private let categoriesProvider: ICategoriesProvider

	private var actions: ((YPViewController.Event) -> Void)?

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

	func viewIsReady(actions: ((YPViewController.Event) -> Void)?) {
		self.actions = actions

		switch trackerAction {
		case .edit, .new, .save, .cancel:
			break
		case let .selectSchedule(schedule):
			self.schedule = schedule
			self.weekDays = makeWeekDays()
			presenter.present(data: .selectSchedule(schedule, weekDays))
		case let .selectCategory(categoryID):
			categories = categoriesProvider.getCategories()
			presenter.present(data: .selectCategory(categoryID, categories))
		case let .selectFilter(filter):
			presenter.present(data: .selectFilter(filter, TrackerFilter.allValues))
		}
	}

	func didSelectItem(_ index: Int) {
		switch trackerAction {
		case .edit, .new, .save, .cancel:
			break
		case .selectSchedule:
			schedule[index + 1] = !(schedule[index + 1] ?? false)
			presenter.present(data: .selectSchedule(schedule, weekDays))
		case .selectFilter:
			let filter = TrackerFilter.allValues[index]
			presenter.present(data: .selectFilter(filter, TrackerFilter.allValues))
			actions?(.didSelectFilter(filter))
		case .selectCategory:
			let category = categories[index]
			presenter.present(data: .selectCategory(category.id, categories))
			actions?(.didSelectCategory(category.id))
		}
	}

	func didTapActionButton() {
		switch trackerAction {
		case .edit, .new, .selectCategory, .save, .cancel:
			break
		case .selectSchedule:
			actions?(.didSelectSchedule(schedule))
		case .selectFilter:
			break
		}
	}
}

private extension YPInteractor {
	func makeWeekDays() -> [String] {
		let calendar = Calendar.current
		let numDays: Int = calendar.weekdaySymbols.count
		let first: Int = calendar.firstWeekday - 1
		let end: Int = first + numDays - 1

		return (first...end).map { calendar.weekdaySymbols[$0 % numDays].localizedCapitalized }
	}
}
