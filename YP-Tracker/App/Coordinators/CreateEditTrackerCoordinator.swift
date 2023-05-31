import UIKit

final class CreateEditTrackerCoordinator: BaseCoordinator {
	private let factory: IModuleFactory
	private let router: IRouter
	private let trackerAction: Tracker.Action

	var finishFlow: (() -> Void)?

	init(router: IRouter, factory: IModuleFactory, trackerAction: Tracker.Action) {
		self.router = router
		self.factory = factory
		self.trackerAction = trackerAction
	}

	override func start() {
		showCreateEditTrackerModule()
	}

	deinit {
		print("CreateEditTrackerCoordinator deinit")
	}
}

// MARK: - show Modules
private extension CreateEditTrackerCoordinator {
	func showCreateEditTrackerModule() {
		let module = factory.makeCreateEditTrackerModule(trackerAction: trackerAction)
		let moduleVC = module as? CreateEditTrackerViewController

		moduleVC?.didSendEventClosure = { [weak self] event in
			if case Tracker.Action.save = event {
				// надо подумать как сохранить, а пока
				self?.router.dismissModule()
				self?.finishFlow?()
			}

			if case Tracker.Action.cancel = event {
				self?.router.dismissModule()
				self?.finishFlow?()
			}
		}

		moduleVC?.title = makeTitle()
		router.present(UINavigationController(rootViewController: module))
	}
}

private extension CreateEditTrackerCoordinator {
	enum Appearance {
		static let titleHabitVC = "Новая привычка"
		static let titleEventVC = "Новое нерегулярное событие"
	}

	func makeTitle() -> String {
		if case Tracker.Action.new(.habit) = trackerAction {
			return Appearance.titleHabitVC
		} else {
			return Appearance.titleEventVC
		}
	}
}
