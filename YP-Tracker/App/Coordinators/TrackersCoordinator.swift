import UIKit

final class TrackersCoordinator: BaseCoordinator {
	private let factory: IModuleFactory
	private let router: IRouter

	private var onUpdateConditions: ((TrackerConditions) -> Void)?
	private var conditions: TrackerConditions {
		didSet(newValue) {
			if conditions != newValue {
				onUpdateConditions?(conditions)
			}
		}
	}
	private var schedule: [Int: Bool] = [:] // в отдельный метод

	var finishFlow: (() -> Void)?

	init(router: IRouter, factory: IModuleFactory) {
		self.router = router
		self.factory = factory

		self.conditions = TrackerConditions(
			date: Date(),
			searchText: "",
			filter: .today,
			hasAnyTrackers: false
		)
	}

	override func start() {
		showTrackersModule()
	}

	deinit {
		print("TrackersCoordinator deinit")
	}
}

// MARK: - show Modules
private extension TrackersCoordinator {
	func showTrackersModule() {
		let module = factory.makeTrackersModule()
		let moduleVC = module as? TrackersViewController

		onUpdateConditions = { [weak moduleVC] conditions in
			moduleVC?.updateConditions(conditions: conditions)
		}
		moduleVC?.didSendEventClosure = { [weak self] event in
			switch event {
			case let .addTracker(conditions):
				self?.conditions = conditions
				self?.showSelectTypeTrackerModule()
			case let .selectFilter(conditions):
				self?.conditions = conditions
				self?.showSelectFilterModule()
			}
		}

		router.setRootModule(module)
	}

	func showSelectFilterModule() {
		let module = factory.makeYPModule(
			trackerAction: .selectFilter(conditions.filter)
		)
		let moduleVC = module as? YPViewController
		moduleVC?.didSendEventClosure = { [weak self] event in
			switch event {
			case let .didSelectFilter(filter):
				self?.conditions.filter = filter
				self?.router.dismissModule()
			case .didSelectSchedule, .didSelectCategory:
				break
			}
		}
		moduleVC?.title = Appearance.titleFiltersVC
		router.present(UINavigationController(rootViewController: module))
	}

	func showSelectTypeTrackerModule() {
		let module = factory.makeSelectTypeTrackerModule()
		let moduleVC = module as? SelectTypeTrackerViewController
		moduleVC?.didSendEventClosure = { [weak self] event in
			let action: (() -> Void)
			switch event {
			case .habit:
				action = {
					print("Запуск создания нового трекера привычки")
					self?.createNewSchedule()
					self?.router.dismissModule()
				}
			case .event:
				action = {
					print("Запуск создания нового трекера события")
					self?.schedule = [:]
					self?.router.dismissModule()
				}
			}
			return action
		}
		router.present(UINavigationController(rootViewController: module))
	}
}

private extension TrackersCoordinator {
	func createNewSchedule() {
		let currentWeekday = Calendar.current.component(
			.weekday,
			from: conditions.date
		)
		var schedule = Dictionary(uniqueKeysWithValues: (1...7).map { ($0, false) })
		schedule[currentWeekday] = true

		self.schedule = schedule
	}
}

private extension TrackersCoordinator {
	enum Appearance {
		static let titleFiltersVC = "Фильтры"
	}
}
