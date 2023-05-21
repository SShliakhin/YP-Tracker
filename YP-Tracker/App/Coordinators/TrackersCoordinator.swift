import UIKit
final class TrackersCoordinator: BaseCoordinator {
	private let factory: IModuleFactory
	private let router: IRouter

	private var conditions: TrackerConditions
	private var scheduler: [Int: Bool] = [:] // в отдельный метод

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
		let module = factory.makeTrackersModule(conditions: conditions)
		let moduleVC = module as? TrackersViewController
		moduleVC?.didSendEventClosure = { event in
			switch event {
			case let .addTracker(conditions):
				self.conditions = conditions
				self.showSelectTypeTrackerModule()
			case let .selectFilter(conditions):
				self.conditions = conditions
				self.showSelectFilterModule()
			}
		}
//		moduleVC?.didSendEventButtonClosure = { event in
//			let action: (() -> Void)
//			switch event {
//			case .addTracker:
//				action = {}
//			case let .selectFilter(conditions):
//				action = {
//					self.conditions = conditions
//					self.showSelectFilterModule()
//				}
//			}
//			return action
//		}
		router.setRootModule(module)
	}

	func showSelectFilterModule() {
		let module = factory.makeYPModule(
			trackerAction: .selectFilter(conditions.filter)
		)
		let moduleVC = module.viewControllers.first as? YPViewController
		moduleVC?.didSendEventClosure = { event in
			switch event {
			case let .didSelectFilter(filter):
				self.conditions.filter = filter
				self.router.dismissModule()
				self.start()
			}
		}
		router.present(module)
	}

	func showSelectTypeTrackerModule() {
		let module = factory.makeSelectTypeTrackerModule()
		let moduleVC = module.viewControllers.first as? SelectTypeTrackerViewController
		moduleVC?.didSendEventClosure = { event in
			let action: (() -> Void)
			switch event {
			case .habit:
				action = {
					print("Запуск создания нового трекера привычки")
					let currentWeekday = Calendar.current.component(
						.weekday,
						from: self.conditions.date
					)
					self.scheduler = Dictionary(uniqueKeysWithValues: (1...7).map { ($0, false) })
					self.scheduler[currentWeekday] = true
					self.router.dismissModule()
				}
			case .event:
				action = {
					print("Запуск создания нового трекера события")
					self.scheduler = [:]
					self.router.dismissModule()
				}
			}
			return action
		}
		router.present(module)
	}
}
