final class StatisticsCoordinator: BaseCoordinator {
	private let factory: IModuleFactory
	private let router: Router

	var finishFlow: (() -> Void)?

	init(router: Router, factory: IModuleFactory) {
		self.router = router
		self.factory = factory
	}

	override func start() {}

	deinit {
		print("TrackersCoordinator deinit")
	}
}

// MARK: - show Modules
private extension StatisticsCoordinator {}
