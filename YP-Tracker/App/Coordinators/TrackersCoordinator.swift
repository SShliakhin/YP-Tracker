import UIKit
final class TrackersCoordinator: BaseCoordinator {
	private let factory: IModuleFactory
	private let router: IRouter

	private var filter = TrackerFilter.today
	private var filterDate = Date()
	private var filterText = ""

	private var tempTracker: Tracker?
	private var scheduler: [Int: Bool] = [:]

	var finishFlow: (() -> Void)?

	init(router: IRouter, factory: IModuleFactory) {
		self.router = router
		self.factory = factory
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
		moduleVC?.didSendEventClosure = { event in
			switch event {
			case .addTracker:
				self.showSelectTypeTrackerModule()
			}
		}
		router.setRootModule(module)
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
					let currentWeekday = Calendar.current.component(.weekday, from: self.filterDate)
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
