// MARK: - ServicesFactory

import Foundation

protocol IServiceFactory {
	func makeLocalFilesProvider() -> FileManager
	func makeCategoriesManager(repository: ICategoriesRepository) -> ICategoriesManager
	func makeCategoriesProvider(manager: ICategoriesManager) -> ICategoriesProvider
}

extension Di: IServiceFactory {
	func makeLocalFilesProvider() -> FileManager {
		FileManager.default
	}

	func makeCategoriesManager(repository: ICategoriesRepository) -> ICategoriesManager {
		return CategoriesManager(
			trackers: repository.getTrackers(),
			categories: repository.getCategories(),
			completedTrackers: repository.getCompletedTrackers()
		)
	}

	func makeCategoriesProvider(manager: ICategoriesManager) -> ICategoriesProvider {
		return CategoriesProvider(categoriesManager: manager)
	}
}
