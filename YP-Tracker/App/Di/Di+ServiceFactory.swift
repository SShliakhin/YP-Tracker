// MARK: - ServicesFactory

import Foundation

protocol IServiceFactory {
	func makeLocalFilesProvider() -> FileManager
	func makeCategoriesProvider() -> ICategoriesProvider
}

extension Di: IServiceFactory {
	func makeLocalFilesProvider() -> FileManager {
		FileManager.default
	}
	func makeCategoriesProvider() -> ICategoriesProvider {
		let repository = TrackerCategoriesStub()

		let categoriesManager = CategoriesManager(
			trackers: repository.getTrackers(),
			categories: repository.getCategories(),
			completedTrackers: repository.getCompletedTrackers()
		)

		return CategoriesProvider(categoriesManager: categoriesManager)
	}
}
