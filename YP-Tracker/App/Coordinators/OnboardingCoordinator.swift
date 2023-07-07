final class OnboardingCoordinator: BaseCoordinator {
	private let factory: IModuleFactory
	private let router: Router

	var finishFlow: (() -> Void)?

	init(router: Router, factory: IModuleFactory) {
		self.router = router
		self.factory = factory
	}

	override func start() {
		showOnboardingModule()
	}

	deinit {
		print("OnboardingCoordinator deinit")
	}
}

// MARK: - show Modules
private extension OnboardingCoordinator {
	func showOnboardingModule() {
		let (module, moduleInteractor) = factory.makeOnboardingModule()
		moduleInteractor.didSendEventClosure = { [weak self] event in
			switch event {
			case .finishOnboarding:
				self?.finishFlow?()
			}
		}
		router.setRootModule(module)
	}
}
