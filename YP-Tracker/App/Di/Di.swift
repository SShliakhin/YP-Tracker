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

protocol IEmptyDependency {}

typealias AllDependencies = (
	IEmptyDependency &
	IAboutModuleDependency &
	ITrackersModuleDependency
)

// MARK: - ModuleFactory

extension Di: IModuleFactory {
	func makeStartModule() -> UIViewController {
		let view = makeCreateEditTrackerModule(trackerAction: .selectFilter(.today))
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
	func makeTrackersModule() -> UIViewController {
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
