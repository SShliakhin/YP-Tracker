// MARK: - CoordinatorFactory

import UIKit

protocol ICoordinatorFactory {
	func makeApplicationCoordinator(router: Router) -> AppCoordinator
	func makeOnboardingCoordinator(router: Router) -> OnboardingCoordinator
	func makeTabbarCoordinator(router: Router) -> TabbarCoordinator
	func makeTrackersCoordinator(navController: UINavigationController) -> TrackersCoordinator
	func makeCreateEditTrackerCoordinator(router: Router, trackerAction: Tracker.Action) -> CreateEditTrackerCoordinator
}

extension Di {
	func makeApplicationCoordinator(router: Router, dep: AllDependencies) -> AppCoordinator {
		AppCoordinator(router: router, factory: self, dep: dep)
	}
}
