import UIKit

// MARK: - ModuleFactory

protocol IModuleFactory: AnyObject {
	func makeStartModule() -> UIViewController
	func makeOnboardingModule() -> (UIViewController, IOnboardingInteractor)
	func makeTabbarModule() -> UIViewController
	func makeStatisticsModule() -> UIViewController
	func makeTrackersModule() -> (UIViewController, ITrackersInteractor)
	func makeSelectTypeTrackerModule() -> (UIViewController, ISelectTypeTrackerInteractor)
	func makeYPModule(trackerAction: Tracker.Action) -> (UIViewController, IYPInteractor)
	func makeCreateEditTrackerModule(trackerAction: Tracker.Action) -> (UIViewController, ICreateEditTrackerInteractor)
	func makeCreateEditCategoryModule(trackerAction: Tracker.Action) -> (UIViewController, ICreateEditCategoryInteractor)
	func makeCoreDataTrainerModule() -> UIViewController

	// Study MVVM
	func makeCategoriesListModuleMVVM(trackerAction: Tracker.Action) -> (UIViewController, CategoriesListViewModel)
}

extension Di {
	func makeOnboardingModule(dep: AllDependencies) -> (UIViewController, IOnboardingInteractor) {
		let interactor = OnboardingInteractor()
		let pageViewController = makeOnboardingPageViewController()
		let view = OnboardingViewController(
			interactor: interactor,
			pageViewController: pageViewController
		)

		return (view, interactor)
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

	func makeCategoriesListModuleMVVM(
		dep: AllDependencies,
		trackerAction: Tracker.Action
	) -> (UIViewController, CategoriesListViewModel) {
		let viewModel = DefaultCategoriesListViewModel(
			dep: dep,
			trackerAction: trackerAction
		)
		let view = SelectCategoryViewController(viewModel: viewModel)

		return (view, viewModel)
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

private extension Di {
	func makeOnboardingPageViewController() -> UIPageViewController {
		var pages: [UIViewController] = []
		for page in OnboardingPage.allCases {
			pages.append(OnboardingPageViewController(page: page))
		}

		return PageViewController(viewControllers: pages)
	}
}
