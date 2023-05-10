import UIKit
final class Di {
	// MARK: - глобальные сервисы-зависимости

	private var dependencies: AllDependencies! // swiftlint:disable:this implicitly_unwrapped_optional

	// MARK: - Inits

	init() {
		// MARK: - инициализация глобальных сервисов

		// MARK: - подготовка локальных сервисов
		dependencies = Dependency(
			localFilesProvider: makeLocalFilesProvider()
		)
	}

	struct Dependency: AllDependencies {
		let localFilesProvider: FileManager
	}
}

// MARK: - Module Dependency

protocol IAboutModuleDependency {
	var localFilesProvider: FileManager { get }
}

typealias AllDependencies = (IAboutModuleDependency)

// MARK: - ModuleFactory

extension Di: ModuleFactory {
	func makeStartModule() -> UIViewController {
		makeAboutModule()
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
}
