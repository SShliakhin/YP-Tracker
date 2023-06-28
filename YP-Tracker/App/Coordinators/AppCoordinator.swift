final class AppCoordinator: BaseCoordinator {
	private let factory: ICoordinatorFactory
	private let router: Router

	private var hadOnboarding = false

	init(router: Router, factory: ICoordinatorFactory) {
		self.router = router
		self.factory = factory
	}

	override func start() {
		if hadOnboarding {
			runMainFlow()
		} else {
			runOnboardingFlow()
		}
	}
}

// MARK: - run Flows
private extension AppCoordinator {
	func runOnboardingFlow() {
		let coordinator = factory.makeOnboardingCoordinator(router: router)
		coordinator.finishFlow = { [weak self, weak coordinator] in
			self?.hadOnboarding = true
			self?.start()
			self?.removeDependency(coordinator)
		}
		coordinator.start()
		childCoordinators.append(coordinator)
	}

	func runMainFlow() {
		let coordinator = factory.makeTabbarCoordinator(router: router)
		coordinator.start()
		childCoordinators.append(coordinator)
	}
}
