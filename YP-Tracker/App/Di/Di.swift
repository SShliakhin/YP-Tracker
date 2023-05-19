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

typealias AllDependencies = (
	IAboutModuleDependency &
	ITrackersModuleDependency
)

// MARK: - ModuleFactory

extension Di: IModuleFactory {
	func makeStartModule() -> UIViewController {
		makeSelectTypeTrackerModule()
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
	func makeSelectTypeTrackerModule() -> UINavigationController {
		makeSelectTypeTrackerModule(dep: dependencies)
	}
}
