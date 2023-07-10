// MARK: - ServicesFactory

import Foundation

protocol IServiceFactory {
	func makeCategoriesManager(repository: ICategoriesRepository) -> ICategoriesManager
	func makeCategoriesManager(dataStore: ITrackersDataStore) -> ICategoriesManager
	func makeCategoriesProvider(manager: ICategoriesManager) -> ICategoriesProvider
	func makeLocalState() -> ILocalState
	func makeAnalyticsService() -> IAnalyticsService
}

extension Di: IServiceFactory {
	func makeCategoriesManager(repository: ICategoriesRepository) -> ICategoriesManager {
		return CategoriesManager(
			trackers: repository.getTrackers(),
			categories: repository.getCategories(),
			completedTrackers: repository.getCompletedTrackers()
		)
	}

	func makeCategoriesManager(dataStore: ITrackersDataStore) -> ICategoriesManager {
		return CategoriesManagerCD(persistentContainer: dataStore.persistentContainer)
	}

	func makeCategoriesProvider(manager: ICategoriesManager) -> ICategoriesProvider {
		return CategoriesProvider(categoriesManager: manager)
	}

	func makeLocalState() -> ILocalState {
		LocalState(localStateStorage: UserDefaults.standard)
	}

	func makeAnalyticsService() -> IAnalyticsService {
		AnalyticsService()
	}
}
