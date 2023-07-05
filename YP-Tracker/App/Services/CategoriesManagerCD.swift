import Foundation
import CoreData

final class CategoriesManagerCD {
	private let persistentContainer: NSPersistentContainer

	private var mainContext: NSManagedObjectContext {
		persistentContainer.viewContext
	}

	private var backgroundContext: NSManagedObjectContext {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		context.parent = self.mainContext
		return context
	}

	init(persistentContainer: NSPersistentContainer) {
		self.persistentContainer = persistentContainer
	}
}

// MARK: - ICategoriesManager

extension CategoriesManagerCD: ICategoriesManager {
	func getCategories() -> [TrackerCategory] {
		let request = TrackerCategoryCD.fetchRequest()
		request.sortDescriptors = [
			NSSortDescriptor(
				key: "title",
				ascending: true,
				selector: #selector(NSString.localizedStandardCompare(_:))
			)
		]
		let objects = runRequest(request)
		return objects.compactMap { TrackerCategory.convertFromCD(object: $0) }
	}

	func getTrackers() -> [Tracker] {
		let request = TrackerCD.fetchRequest()
		request.sortDescriptors = [
			NSSortDescriptor(
				key: "title",
				ascending: true,
				selector: #selector(NSString.localizedStandardCompare(_:))
			)
		]
		let objects = runRequest(request)
		return objects.compactMap { Tracker.convertFromCD(object: $0) }
	}

	func getCompletedTrackers() -> [TrackerRecord] {
		let request = TrackerRecordCD.fetchRequest()
		request.sortDescriptors = [
			NSSortDescriptor(
				key: "dateString",
				ascending: true,
				selector: #selector(NSString.localizedStandardCompare(_:))
			)
		]
		let objects = runRequest(request)
		return objects.compactMap { TrackerRecord.convertFromCD(object: $0) }
	}

	// swiftlint:disable:next large_tuple
	func getTrackerEditBoxByID(_ trackerID: UUID) -> (Tracker, UUID, String)? {
		guard let trackerCD = findObjectByUUID(
			id: trackerID,
			key: "trackerID",
			withRequest: TrackerCD.fetchRequest()
		) else { return nil }
		guard let categoryCD = trackerCD.trackerCategory else { return nil }
		guard
			let tracker = Tracker.convertFromCD(object: trackerCD),
			let categoryID = categoryCD.categoryID,
			let categoryTitle = categoryCD.title
		else { return nil }
		return (tracker, categoryID, categoryTitle)
	}

	func addCategory(title: String) {
		// как вариант можно поискать по названию уже имеющуюся
		// удалить вокруг пробелы и не учитывать регистр
		// на потом, пока не требуется добавлять
		let categoryCD = TrackerCategoryCD(context: mainContext)
		categoryCD.categoryID = UUID()
		categoryCD.title = title
		mainContext.saveContext()
	}

	func editCategoryBy(categoryID: UUID, newtitle: String) {
		// то же самое что и выше, нельзя допускать одинаковых категорий
		guard let categoryCD = findObjectByUUID(
			id: categoryID,
			key: "categoryID",
			withRequest: TrackerCategoryCD.fetchRequest()
		) else { return }
		categoryCD.title = newtitle
		mainContext.saveContext()
	}

	func removeCategoryBy(categoryID: UUID) {
		guard let categoryCD = findObjectByUUID(
			id: categoryID,
			key: "categoryID",
			withRequest: TrackerCategoryCD.fetchRequest()
		) else { return }
		mainContext.delete(categoryCD)
		mainContext.saveContext()
	}

	func addTracker(tracker: Tracker, categoryID: UUID) {
		updateCreateTracker(from: tracker, withCategoryID: categoryID)
	}

	func editTracker(tracker: Tracker, categoryID: UUID) {
		updateCreateTracker(from: tracker, withCategoryID: categoryID)
	}

	func removeTrackerBy(trackerID: UUID) {
		guard let trackerCD = findObjectByUUID(
			id: trackerID,
			key: "trackerID",
			withRequest: TrackerCD.fetchRequest()
		) else { return }
		mainContext.delete(trackerCD)
		mainContext.saveContext()
	}

	func addCompletedTracker(trackerID: UUID, date: Date) {
		completeUncompletedTracker(
			trackerID: trackerID,
			date: date
		)
	}

	func cancelCompletedTracker(trackerID: UUID, date: Date) {
		completeUncompletedTracker(
			trackerID: trackerID,
			date: date
		)
	}
}

private extension CategoriesManagerCD {
	func runRequest<T: NSManagedObject>(
		_ request: NSFetchRequest<T>
	) -> [T] {
		var result: [T] = []
		do {
			result = try mainContext.fetch(request)
		} catch let error as NSError {
			let message = "При выполнении запроса Core Data произошла ошибка:"
			print(message, error, error.userInfo)
		}
		return result
	}

	func findObjectByUUID<T: NSManagedObject>(
		id: UUID,
		key: String,
		withRequest request: NSFetchRequest<T>
	) -> T? {
		request.predicate = NSPredicate(format: "\(key) == %@", id as CVarArg)
		request.fetchLimit = 1
		guard let object = runRequest(request).first else { return nil }
		return object
	}

	func updateCreateTracker(
		from tracker: Tracker,
		withCategoryID categoryID: UUID
	) {
		guard let categoryCD = findObjectByUUID(
			id: categoryID,
			key: "categoryID",
			withRequest: TrackerCategoryCD.fetchRequest()
		) else { return }

		let trackerCD: TrackerCD
		if let foundTrackerCD = findObjectByUUID(
			id: tracker.id,
			key: "trackerID",
			withRequest: TrackerCD.fetchRequest()
		) {
			trackerCD = foundTrackerCD
		} else {
			trackerCD = TrackerCD(context: mainContext)
		}

		trackerCD.trackerID = tracker.id
		trackerCD.title = tracker.title
		trackerCD.emoji = tracker.emoji
		trackerCD.color = tracker.color
		trackerCD.schedule = tracker.scheduleCD
		trackerCD.trackerCategory = categoryCD
		mainContext.saveContext()
	}

	func completeUncompletedTracker(
		trackerID: UUID,
		date: Date
	) {
		guard let trackerCD = findObjectByUUID(
			id: trackerID,
			key: "trackerID",
			withRequest: TrackerCD.fetchRequest()
		) else { return }

		let dateString = Theme.dateFormatterCD.string(from: date)

		let request = TrackerRecordCD.fetchRequest()
		request.predicate = NSPredicate(
			format: "trackerID == %@ && dateString == %@",
			trackerID as CVarArg,
			dateString
		)

		if let trackerRecordCD = runRequest(request).first {
			mainContext.delete(trackerRecordCD)
		} else {
			let trackerRecordCD = TrackerRecordCD(context: mainContext)
			trackerRecordCD.trackerID = trackerID
			trackerRecordCD.dateString = dateString
			trackerRecordCD.tracker = trackerCD
		}
		mainContext.saveContext()
	}
}

// MARK: - Расширения доменных моделей - конвертации из объектов CD

extension TrackerCategory {
	static func convertFromCD(object: NSManagedObject) -> TrackerCategory? {
		guard
			let trackerCategoryCD = object as? TrackerCategoryCD,
			let id = trackerCategoryCD.categoryID,
			let title = trackerCategoryCD.title
		else { return nil }

		let trackersCD = trackerCategoryCD.trackers?.array as? [TrackerCD] ?? []
		let trackers = trackersCD.compactMap { Tracker.convertFromCD(object: $0)?.id }

		return TrackerCategory(
			id: id,
			title: title,
			trackers: trackers
		)
	}
}

extension Tracker {
	static func convertFromCD(object: NSManagedObject) -> Tracker? {
		guard
			let trackerCD = object as? TrackerCD,
			let id = trackerCD.trackerID,
			let title = trackerCD.title,
			let emoji = trackerCD.emoji,
			let color = trackerCD.color,
			let scheduleString = trackerCD.schedule
		else { return nil }

		var schedule: [Int: Bool] = [:]
		if !scheduleString.isEmpty {
			// "0,2,3,4,0,6,7" - превратить в словарь
			schedule = scheduleString.components(separatedBy: ",")
				.enumerated()
				.reduce(into: [:]) { result, keyValue in
					if let number = Int(keyValue.element) {
						result[keyValue.offset + 1] = number != 0
					}
				}
		}

		return Tracker(
			id: id,
			title: title,
			emoji: emoji,
			color: color,
			schedule: schedule
		)
	}
}

extension TrackerRecord {
	static func convertFromCD(object: NSManagedObject) -> TrackerRecord? {
		guard
			let trackerRecordCD = object as? TrackerRecordCD,
			let id = trackerRecordCD.trackerID,
			let dateString = trackerRecordCD.dateString
		else { return nil }

		// с проверкой даты не знаю что пока делать
		let date = Theme.dateFormatterCD.date(from: dateString) ?? Date()
		return TrackerRecord(trackerId: id, date: date)
	}
}
