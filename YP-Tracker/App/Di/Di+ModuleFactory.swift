import UIKit

// MARK: - ModuleFactory

protocol IModuleFactory: AnyObject {
	func makeStartModule() -> UIViewController
	func makeAboutModule() -> UIViewController
	func makeMainSimpleModule() -> UIViewController
	func makeOnboardingModule() -> UIViewController
	func makeTabbarModule() -> UIViewController
	func makeStatisticsModule() -> UIViewController
	func makeTrackersModule() -> UIViewController
	func makeSelectTypeTrackerModule() -> UINavigationController
}

extension Di {
	func makeAboutModule(dep: AllDependencies) -> UIViewController {
		let presenter = AboutPresenter()
		let worker = AboutWorker()
		let interactor = AboutInteractor(
			worker: worker,
			presenter: presenter,
			dep: dep
		)
		let view = AboutViewController(interactor: interactor)
		presenter.viewController = view

		return view
	}

	func makeMainSimpleModule(dep: AllDependencies) -> UIViewController {
		return MainSimpleViewController()
	}

	func makeOnboardingModule(dep: AllDependencies) -> UIViewController {
		return OnboardingViewController()
	}

	func makeTabbarModule(dep: AllDependencies) -> UIViewController {
		return TabbarViewController()
	}

	func makeStatisticsModule(dep: AllDependencies) -> UIViewController {
		return StatisticsViewController()
	}

	func makeTrackersModule(dep: AllDependencies) -> UIViewController {
		return TrackersViewController()
	}

	func makeSelectTypeTrackerModule(dep: AllDependencies) -> UINavigationController {
		return UINavigationController(rootViewController: SelectTypeTrackerViewController())
	}
}
