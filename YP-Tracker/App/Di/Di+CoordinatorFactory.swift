// MARK: - CoordinatorFactory

protocol ICoordinatorFactory {
	func makeApplicationCoordinator(router: IRouter) -> AppCoordinator
	func makeOnboardingCoordinator(router: IRouter) -> OnboardingCoordinator
	func makeMainSimpleCoordinator(router: IRouter) -> MainSimpleCoordinator
	func makeAboutCoordinator(router: IRouter) -> AboutCoordinator
}

extension Di: ICoordinatorFactory {
	func makeApplicationCoordinator(router: IRouter) -> AppCoordinator {
		AppCoordinator(router: router, factory: self)
	}
	func makeOnboardingCoordinator(router: IRouter) -> OnboardingCoordinator {
		OnboardingCoordinator(router: router, factory: self)
	}
	func makeMainSimpleCoordinator(router: IRouter) -> MainSimpleCoordinator {
		MainSimpleCoordinator(router: router, factory: self, coordinatorFactory: self)
	}
	func makeAboutCoordinator(router: IRouter) -> AboutCoordinator {
		AboutCoordinator(router: router, factory: self)
	}
}
