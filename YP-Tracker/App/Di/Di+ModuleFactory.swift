import UIKit

// MARK: - ModuleFactory

protocol IModuleFactory: AnyObject {
	func makeStartModule() -> UIViewController
	func makeOnboardingModule() -> UIViewController
	func makeTabbarModule() -> UIViewController
	func makeStatisticsModule() -> UIViewController
	func makeTrackersModule() -> (UIViewController, ITrackersInteractor)
	func makeSelectTypeTrackerModule() -> (UIViewController, ISelectTypeTrackerInteractor)
	func makeYPModule(trackerAction: Tracker.Action) -> (UIViewController, IYPInteractor)
	func makeCreateEditTrackerModule(trackerAction: Tracker.Action) -> (UIViewController, ICreateEditTrackerInteractor)
	func makeCreateEditCategoryModule(trackerAction: Tracker.Action) -> (UIViewController, ICreateEditCategoryInteractor)
	func makeCoreDataTrainerModule() -> UIViewController
}

extension Di {
	func makeOnboardingModule(dep: AllDependencies) -> UIViewController {
		return OnboardingViewController()
	}

	func makeCoreDataTrainerModule(dep: AllDependencies) -> UIViewController {
		return CoreDataTrainerViewController()
	}

	func makeTabbarModule(dep: AllDependencies) -> UIViewController {
		return TabbarViewController()
	}

	func makeStatisticsModule(dep: AllDependencies) -> UIViewController {
		return StatisticsViewController()
	}

	func makeTrackersModule(
		dep: AllDependencies
	) -> (UIViewController, ITrackersInteractor) {
		let presenter = TrackersPresenter()
		let interactor = TrackersInteractor(
			presenter: presenter,
			dep: dep
		)
		let view = TrackersViewController(interactor: interactor)
		presenter.viewController = view

		return (view, interactor)
	}

	func makeSelectTypeTrackerModule(
		dep: AllDependencies
	) -> (UIViewController, ISelectTypeTrackerInteractor) {
		let interactor = SelectTypeTrackerInteractor()
		let view = SelectTypeTrackerViewController(interactor: interactor)
		return (view, interactor)
	}

	func makeYPModule(
		dep: AllDependencies,
		trackerAction: Tracker.Action
	) -> (UIViewController, IYPInteractor) {
		let presenter = YPPresenter()
		let interactor = YPInteractor(
			presenter: presenter,
			dep: dep,
			trackerAction: trackerAction
		)
		let view = YPViewController(interactor: interactor)
		presenter.viewController = view

		return (view, interactor)
	}

	func makeCreateEditTrackerModule(
		dep: AllDependencies,
		trackerAction: Tracker.Action
	) -> (UIViewController, ICreateEditTrackerInteractor) {
		let presenter = CreateEditTrackerPresenter()
		let interactor = CreateEditTrackerInteractor(
			presenter: presenter,
			dep: dep,
			trackerAction: trackerAction
		)
		let view = CreateEditTrackerViewController(interactor: interactor)
		presenter.viewController = view

		return (view, interactor)
	}

	func makeCreateEditCategoryModule(
		dep: AllDependencies,
		trackerAction: Tracker.Action
	) -> (UIViewController, ICreateEditCategoryInteractor) {
		let presenter = CreateEditCategoryPresenter()
		let interactor = CreateEditCategoryInteractor(
			presenter: presenter,
			dep: dep,
			trackerAction: trackerAction
		)
		let view = CreateEditCategoryViewController(interactor: interactor)
		presenter.viewController = view

		return (view, interactor)
	}
}
