import UIKit
final class Di {
	// MARK: - глобальные сервисы-зависимости
	// по идее должны приходить извне
	// private let repository = TrackerCategoriesStub()
	// пока не знаю что лучше передавать в инит di сам стек или только имя модели
	private let trackersDataStore = CoreDataStack(modelName: "TrackersMOC")

	private var dependencies: AllDependencies! // swiftlint:disable:this implicitly_unwrapped_optional

	// MARK: - Inits

	init() {
		// MARK: - инициализация глобальных сервисов
		// вариант для работы в ОП
		// let categoriesManager = makeCategoriesManager(repository: repository)
		// вариант для работы с постоянным хранилищем
		let categoriesManager = makeCategoriesManager(dataStore: trackersDataStore)
		let statisticsService = makeStatisticsService()

		// MARK: - подготовка локальных сервисов
		dependencies = Dependency(
			localState: makeLocalState(),
			categoriesManager: categoriesManager,
			categoriesProvider: makeCategoriesProvider(manager: categoriesManager),
			analyticsService: makeAnalyticsService(),
			statisticsIn: statisticsService,
			statisticsOut: statisticsService
		)
	}

	struct Dependency: AllDependencies {
		let localState: ILocalState
		let categoriesManager: ICategoriesManager
		let categoriesProvider: ICategoriesProvider
		let analyticsService: IAnalyticsService
		let statisticsIn: StatisticsIn
		let statisticsOut: StatisticsOut
	}
}

// MARK: - Module Dependency

protocol ITrackersModuleDependency {
	var categoriesProvider: ICategoriesProvider { get }
	var analyticsService: IAnalyticsService { get }
	var statisticsIn: StatisticsIn { get }
}

protocol IStatisticsModuleDependency {
	var statisticsOut: StatisticsOut { get }
}

protocol IYPModuleDependency {
	var categoriesProvider: ICategoriesProvider { get }
}

protocol ICreateEditTrackerModuleDependency {
	var categoriesManager: ICategoriesManager { get }
}

protocol ICreateEditCategoryModuleDependency {
	var categoriesManager: ICategoriesManager { get }
}

protocol IAppCoordinatorDependcy {
	var localState: ILocalState { get }
}

protocol IEmptyDependency {}

typealias AllDependencies = (
	IEmptyDependency &
	IAppCoordinatorDependcy &
	ITrackersModuleDependency &
	IStatisticsModuleDependency &
	ICreateEditTrackerModuleDependency &
	ICreateEditCategoryModuleDependency &
	IYPModuleDependency
)

// MARK: - ICoordinatorFactory

extension Di: ICoordinatorFactory {
	func makeApplicationCoordinator(router: Router) -> AppCoordinator {
		makeApplicationCoordinator(router: router, dep: dependencies)
	}
	func makeOnboardingCoordinator(router: Router) -> OnboardingCoordinator {
		OnboardingCoordinator(router: router, factory: self)
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
	func makeStatisticsCoordinator(navController: UINavigationController) -> StatisticsCoordinator {
		StatisticsCoordinator(
			router: Router(rootController: navController),
			factory: self
		)
	}
	func makeCreateEditTrackerCoordinator(router: Router, trackerAction: Tracker.Action) -> CreateEditTrackerCoordinator {
		CreateEditTrackerCoordinator(router: router, factory: self, trackerAction: trackerAction)
	}
}

// MARK: - ModuleFactory

extension Di: IModuleFactory {
	func makeStartModule() -> UIViewController {
		// Вспомогательный метод, для отдельного запуска сцен
		// при let isOnlyScene = true в SceneDelegate
		// makeOnboardingModule().0
		let view = makeCategoriesListModuleMVVM(trackerAction: .selectCategory(nil)).0
		view.title = "Категория"
		return UINavigationController(rootViewController: view)
	}
	func makeOnboardingModule() -> (UIViewController, IOnboardingInteractor) {
		makeOnboardingModule(dep: dependencies)
	}
	func makeTabbarModule() -> UIViewController {
		makeTabbarModule(dep: dependencies)
	}
	func makeStatisticsModule() -> (UIViewController, StatisticsListViewModel) {
		makeStatisticsModule(dep: dependencies)
	}
	func makeTrackersModule() -> (UIViewController, ITrackersInteractor) {
		makeTrackersModule(dep: dependencies)
	}
	func makeYPModule(trackerAction: Tracker.Action) -> (UIViewController, IYPInteractor) {
		makeYPModule(dep: dependencies, trackerAction: trackerAction)
	}
	func makeCategoriesListModuleMVVM(trackerAction: Tracker.Action) -> (UIViewController, CategoriesListViewModel) {
		makeCategoriesListModuleMVVM(dep: dependencies, trackerAction: trackerAction)
	}
	func makeSelectTypeTrackerModule() -> (UIViewController, ISelectTypeTrackerInteractor) {
		makeSelectTypeTrackerModule(dep: dependencies)
	}
	func makeCreateEditTrackerModule(trackerAction: Tracker.Action) -> (UIViewController, ICreateEditTrackerInteractor) {
		makeCreateEditTrackerModule(dep: dependencies, trackerAction: trackerAction)
	}
	func makeCoreDataTrainerModule() -> UIViewController {
		makeCoreDataTrainerModule(dep: dependencies)
	}
	func makeCreateEditCategoryModule(trackerAction: Tracker.Action) -> (UIViewController, ICreateEditCategoryInteractor) {
		makeCreateEditCategoryModule(dep: dependencies, trackerAction: trackerAction)
	}
}
