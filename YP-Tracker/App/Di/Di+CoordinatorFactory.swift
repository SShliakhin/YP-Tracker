// MARK: - CoordinatorFactory

import UIKit

protocol ICoordinatorFactory {
	func makeApplicationCoordinator(router: Router) -> AppCoordinator
	func makeOnboardingCoordinator(router: Router) -> OnboardingCoordinator
	func makeMainSimpleCoordinator(router: Router) -> MainSimpleCoordinator
	func makeAboutCoordinator(router: Router) -> AboutCoordinator
	func makeTabbarCoordinator(router: Router) -> TabbarCoordinator
	func makeTrackersCoordinator(navController: UINavigationController) -> TrackersCoordinator
	func makeCreateEditTrackerCoordinator(router: Router, trackerAction: Tracker.Action) -> CreateEditTrackerCoordinator
}

extension Di: ICoordinatorFactory {
	func makeApplicationCoordinator(router: Router) -> AppCoordinator {
		AppCoordinator(router: router, factory: self)
	}
	func makeOnboardingCoordinator(router: Router) -> OnboardingCoordinator {
		OnboardingCoordinator(router: router, factory: self)
	}
	func makeMainSimpleCoordinator(router: Router) -> MainSimpleCoordinator {
		MainSimpleCoordinator(router: router, factory: self, coordinatorFactory: self)
	}
	func makeAboutCoordinator(router: Router) -> AboutCoordinator {
		AboutCoordinator(router: router, factory: self)
	}
	func makeTabbarCoordinator(router: Router) -> TabbarCoordinator {
		TabbarCoordinator(router: router, factory: self, coordinatorFactory: self)
	}
	func makeTrackersCoordinator(navController: UINavigationController) -> TrackersCoordinator {
		TrackersCoordinator(
			router: Router(rootController: navController),
			factory: self,
			coordinatorFactory: self
		)
	}
	func makeCreateEditTrackerCoordinator(router: Router, trackerAction: Tracker.Action) -> CreateEditTrackerCoordinator {
		CreateEditTrackerCoordinator(router: router, factory: self, trackerAction: trackerAction)
	}
}
