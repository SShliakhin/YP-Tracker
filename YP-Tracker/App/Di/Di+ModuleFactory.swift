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
	func makeSelectTypeTrackerModule() -> UIViewController
	func makeYPModule(trackerAction: Tracker.Action) -> UIViewController
	func makeCreateEditTrackerModule(trackerAction: Tracker.Action) -> UIViewController
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
		let presenter = TrackersPresenter()
		let interactor = TrackersInteractor(
			presenter: presenter,
			dep: dep
		)
		let view = TrackersViewController(interactor: interactor)
		presenter.viewController = view

		return view
	}

	func makeSelectTypeTrackerModule(dep: AllDependencies) -> UIViewController {
		return SelectTypeTrackerViewController()
	}

	func makeYPModule(dep: AllDependencies, trackerAction: Tracker.Action) -> UIViewController {
		let presenter = YPPresenter()
		let interactor = YPInteractor(
			presenter: presenter,
			dep: dep,
			trackerAction: trackerAction
		)
		let view = YPViewController(interactor: interactor)
		presenter.viewController = view

		return view
	}

	func makeCreateEditTrackerModule(dep: AllDependencies, trackerAction: Tracker.Action) -> UIViewController {
		let presenter = CreateEditTrackerPresenter()
		let interactor = CreateEditTrackerInteractor(
			presenter: presenter,
			dep: dep,
			trackerAction: trackerAction
		)
		let view = CreateEditTrackerViewController(interactor: interactor)
		presenter.viewController = view

		return view
	}
}
