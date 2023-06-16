import Foundation
import CoreData

protocol ITrackersDataStore {
	var persistentContainer: NSPersistentContainer { get }
}

final class CoreDataStack: ITrackersDataStore {

	private let modelName: String

	lazy var persistentContainer: NSPersistentContainer = {

		let container = NSPersistentContainer(name: self.modelName)
		container.loadPersistentStores { storeDescription, error in
			print("DB = \(storeDescription)")
			if let error = error as NSError? {
				print("Error: \(error), \(error.userInfo)")
			}
		}
		return container
	}()

	init(modelName: String) {
		self.modelName = modelName
	}
}

extension NSManagedObjectContext {
	func saveContext() {
		guard self.hasChanges else { return }

		do {
			try save()
		} catch let error as NSError {
			print("Core Data Error: \(error), \(error.userInfo)")
		}
	}
}
