final class AppCoordinator: BaseCoordinator {
	private let factory: ICoordinatorFactory
	private let router: Router
	private var localState: ILocalState

	init(router: Router, factory: ICoordinatorFactory, dep: IAppCoordinatorDependcy) {
		self.router = router
		self.factory = factory
		self.localState = dep.localState
	}

	override func start() {
		if localState.hasOnboarded ?? false {
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
			self?.localState.hasOnboarded = true
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
