import UIKit
final class Di {
	// MARK: - глобальные сервисы-зависимости
	// по идее должны приходить извне
	private let repository = TrackerCategoriesStub()
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

		// MARK: - подготовка локальных сервисов
		dependencies = Dependency(
			categoriesManager: categoriesManager,
			categoriesProvider: makeCategoriesProvider(manager: categoriesManager)
		)
	}

	struct Dependency: AllDependencies {
		let categoriesManager: ICategoriesManager
		let categoriesProvider: ICategoriesProvider
	}
}

// MARK: - Module Dependency

protocol ITrackersModuleDependency {
	var categoriesProvider: ICategoriesProvider { get }
}

protocol IYPModuleDependency {
	var categoriesProvider: ICategoriesProvider { get }
}

protocol ICreateEditTrackerModuleDependency {
	var categoriesManager: ICategoriesManager { get }
}

protocol IEmptyDependency {}

typealias AllDependencies = (
	IEmptyDependency &
	ITrackersModuleDependency &
	ICreateEditTrackerModuleDependency &
	IYPModuleDependency
)

// MARK: - ModuleFactory

extension Di: IModuleFactory {
	func makeStartModule() -> UIViewController {
		// Вспомогательный метод, для отдельного запуска сцен
		// при let isOnlyScene = true в SceneDelegate

		var view = makeCoreDataTrainerModule()
		return view

		// модуль создания трекера
		(view, _) = makeCreateEditTrackerModule(trackerAction: .new(.habit))
		return UINavigationController(rootViewController: view)

		// модуль выбора категории, нужен сервис, кнопка - Добавить категорию
		let categoryID = dependencies.categoriesProvider.getCategories()[1].id
		(view, _) = makeYPModule(trackerAction: .selectCategory(categoryID))
		view.title = "Категория"
		return UINavigationController(rootViewController: view)

		// модуль выбора расписания, кнопка Готово
		let schedule = [
			1: false,
			2: true,
			3: true,
			4: true,
			5: true,
			6: true,
			7: false
		]

		(view, _) = makeYPModule(trackerAction: .selectSchedule(schedule))
		view.title = "Расписание"
		return UINavigationController(rootViewController: view)
	}
	func makeOnboardingModule() -> UIViewController {
		makeOnboardingModule(dep: dependencies)
	}
	func makeTabbarModule() -> UIViewController {
		makeTabbarModule(dep: dependencies)
	}
	func makeStatisticsModule() -> UIViewController {
		makeStatisticsModule(dep: dependencies)
	}
	func makeTrackersModule() -> (UIViewController, ITrackersInteractor) {
		makeTrackersModule(dep: dependencies)
	}
	func makeYPModule(trackerAction: Tracker.Action) -> (UIViewController, IYPInteractor) {
		makeYPModule(dep: dependencies, trackerAction: trackerAction)
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
}
