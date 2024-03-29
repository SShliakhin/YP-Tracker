import Foundation

final class StatisticsCoordinator: BaseCoordinator {
	private let factory: IModuleFactory
	private let router: Router

	var finishFlow: (() -> Void)?

	init(router: Router, factory: IModuleFactory) {
		self.router = router
		self.factory = factory
	}

	override func start() {
		showStatisticsModule()
	}

	deinit {
		print("TrackersCoordinator deinit")
	}
}

// MARK: - show Modules
private extension StatisticsCoordinator {
	func showStatisticsModule() {
		let (module, _) = factory.makeStatisticsModule()
		module.title = ScreensTitles.titleStatisticsVC
		router.setRootModule(module)
	}
}
