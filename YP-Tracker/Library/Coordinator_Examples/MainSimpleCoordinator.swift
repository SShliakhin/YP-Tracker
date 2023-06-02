final class MainSimpleCoordinator: BaseCoordinator {
	private let factory: IModuleFactory
	private let coordinatorFactory: ICoordinatorFactory
	private let router: Router

	var finishFlow: (() -> Void)?

	init(router: Router, factory: IModuleFactory, coordinatorFactory: ICoordinatorFactory) {
		self.router = router
		self.factory = factory
		self.coordinatorFactory = coordinatorFactory
	}

	override func start() {
		showMainSimpleModule()
	}

	deinit {
		print("MainSimpleCoordinator deinit")
	}
}

// MARK: - run Flows
private extension MainSimpleCoordinator {
	func runAboutFlow() {
		let coordinator = coordinatorFactory.makeAboutCoordinator(router: router)
		coordinator.finishFlow = { [weak self, weak coordinator] in
			self?.router.dismissModule()
			self?.removeDependency(coordinator)
			self?.showMainSimpleModule()
		}
		addDependency(coordinator)
		coordinator.start()
	}
	func runOnboardingFlow() {
		let coordinator = coordinatorFactory.makeOnboardingCoordinator(router: router)
		coordinator.finishFlow = { [weak self, weak coordinator] in
			self?.router.dismissModule()
			self?.removeDependency(coordinator)
			self?.showMainSimpleModule()
		}
		addDependency(coordinator)
		coordinator.start()
	}
	func runTabbarFlow() {
		let coordinator = coordinatorFactory.makeTabbarCoordinator(router: router)
		coordinator.finishFlow = { [weak self, weak coordinator] in
			self?.router.dismissModule()
			self?.removeDependency(coordinator)
			self?.showMainSimpleModule()
		}
		addDependency(coordinator)
		coordinator.start()
	}
}

// MARK: - show Modules
private extension MainSimpleCoordinator {
	func showMainSimpleModule() {
		let module = factory.makeMainSimpleModule()
		let moduleVC = module as? MainSimpleViewController
		moduleVC?.didSendEventClosure = { [weak self] event in
			let action: (() -> Void)
			switch event {
			case .onboarding:
				action = {
					self?.runOnboardingFlow()
				}
			case .tab:
				action = {
					self?.runTabbarFlow()
				}
			case .about:
				action = {
					self?.runAboutFlow() // вариант с флоу
					// self.showAboutModule() // вариант без flow
				}
			}
			return action
		}
		router.setRootModule(module)
	}

	func showAboutModule() {
		let module = factory.makeAboutModule()
		let moduleVC = module as? AboutViewController
		moduleVC?.didSendEventClosure = { [weak self] event in
			switch event {
			case .finish:
				self?.showMainSimpleModule()
			}
		}
		router.setRootModule(module)
	}
}
