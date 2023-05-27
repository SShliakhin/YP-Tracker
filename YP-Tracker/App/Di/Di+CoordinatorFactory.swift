// MARK: - CoordinatorFactory

import UIKit

protocol ICoordinatorFactory {
	func makeApplicationCoordinator(router: IRouter) -> AppCoordinator
	func makeOnboardingCoordinator(router: IRouter) -> OnboardingCoordinator
	func makeMainSimpleCoordinator(router: IRouter) -> MainSimpleCoordinator
	func makeAboutCoordinator(router: IRouter) -> AboutCoordinator
	func makeTabbarCoordinator(router: IRouter) -> TabbarCoordinator
	func makeTrackersCoordinator(navController: UINavigationController) -> TrackersCoordinator
	func makeCreateEditTrackerCoordinator(router: IRouter, trackerAction: Tracker.Action) -> CreateEditTrackerCoordinator
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
	func makeTabbarCoordinator(router: IRouter) -> TabbarCoordinator {
		TabbarCoordinator(router: router, factory: self, coordinatorFactory: self)
	}
	func makeTrackersCoordinator(navController: UINavigationController) -> TrackersCoordinator {
		TrackersCoordinator(
			router: Router(rootController: navController),
			factory: self,
			coordinatorFactory: self
		)
	}
	func makeCreateEditTrackerCoordinator(router: IRouter, trackerAction: Tracker.Action) -> CreateEditTrackerCoordinator {
		CreateEditTrackerCoordinator(router: router, factory: self, trackerAction: trackerAction)
	}
}
