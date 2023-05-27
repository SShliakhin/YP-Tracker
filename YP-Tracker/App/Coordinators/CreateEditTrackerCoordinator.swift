import UIKit

final class CreateEditTrackerCoordinator: BaseCoordinator {
	private let factory: IModuleFactory
	private let router: IRouter
	private let trackerAction: Tracker.Action

	// private var trackerTempData: TrackerTempData?

	var finishFlow: (() -> Void)?

	init(router: IRouter, factory: IModuleFactory, trackerAction: Tracker.Action) {
		self.router = router
		self.factory = factory
		self.trackerAction = trackerAction
	}

	override func start() {}

	deinit {
		print("CreateEditTrackerCoordinator deinit")
	}
}

// MARK: - show Modules
private extension CreateEditTrackerCoordinator {
	func showSelectFilterModule() {
		let module = factory.makeCreateEditTrackerModule(trackerAction: trackerAction)
		let moduleVC = module as? CreateEditTrackerViewController
//		moduleVC?.didSendEventClosure = { [weak self] event in
//			switch event {
//			case let .didSelectFilter(filter):
//				self?.conditions.filter = filter
//				self?.router.dismissModule()
//			case .didSelectSchedule, .didSelectCategory:
//				break
//			}
//		}
		moduleVC?.title = Appearance.titleHabitVC
		router.present(UINavigationController(rootViewController: module))
	}
}

private extension CreateEditTrackerCoordinator {
	enum Appearance {
		static let titleHabitVC = "Новая привычка"
		static let titleEventVC = "Новое нерегулярное событие"
	}
}
