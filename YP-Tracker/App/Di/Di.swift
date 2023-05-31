import UIKit
final class Di {
	// MARK: - глобальные сервисы-зависимости

	private var dependencies: AllDependencies! // swiftlint:disable:this implicitly_unwrapped_optional

	// MARK: - Inits

	init() {
		// MARK: - инициализация глобальных сервисов

		// MARK: - подготовка локальных сервисов
		dependencies = Dependency(
			localFilesProvider: makeLocalFilesProvider(),
			categoriesProvider: makeCategoriesProvider()
		)
	}

	struct Dependency: AllDependencies {
		let localFilesProvider: FileManager
		let categoriesProvider: ICategoriesProvider
	}
}

// MARK: - Module Dependency

protocol IAboutModuleDependency {
	var localFilesProvider: FileManager { get }
}

protocol ITrackersModuleDependency {
	var categoriesProvider: ICategoriesProvider { get }
}

protocol IYPModuleDependency {
	var categoriesProvider: ICategoriesProvider { get }
}

protocol IEmptyDependency {}

typealias AllDependencies = (
	IEmptyDependency &
	IAboutModuleDependency &
	ITrackersModuleDependency &
	IYPModuleDependency
)

// MARK: - ModuleFactory

extension Di: IModuleFactory {
	func makeStartModule() -> UIViewController {
		// Вспомогательный метод, для отдельного запуска сцен
		// при let isOnlyScene = true в SceneDelegate

		// модуль создания трекера
		var view = makeCreateEditTrackerModule(trackerAction: .new(.habit))
		return UINavigationController(rootViewController: view)

		// модуль выбора категории, нужен сервис, кнопка - Добавить категорию
		let categoryID = dependencies.categoriesProvider.getCategories()[1].id
		view = makeYPModule(trackerAction: .selectCategory(categoryID))
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

		view = makeYPModule(trackerAction: .selectSchedule(schedule))
		view.title = "Расписание"
		return UINavigationController(rootViewController: view)
	}
	func makeAboutModule() -> UIViewController {
		makeAboutModule(dep: dependencies)
	}
	func makeMainSimpleModule() -> UIViewController {
		makeMainSimpleModule(dep: dependencies)
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
	func makeYPModule(trackerAction: Tracker.Action) -> UIViewController {
		makeYPModule(dep: dependencies, trackerAction: trackerAction)
	}
	func makeSelectTypeTrackerModule() -> UIViewController {
		makeSelectTypeTrackerModule(dep: dependencies)
	}
	func makeCreateEditTrackerModule(trackerAction: Tracker.Action) -> UIViewController {
		makeCreateEditTrackerModule(dep: dependencies, trackerAction: trackerAction)
	}
}
