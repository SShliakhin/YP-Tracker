final class StatisticsCoordinator: BaseCoordinator {
	private let factory: IModuleFactory
	private let router: IRouter

	var finishFlow: (() -> Void)?

	init(router: IRouter, factory: IModuleFactory) {
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
