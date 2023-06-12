import UIKit
import CoreData

final class CoreDataTrainerViewController: UIViewController {
	private var didSendEventClosure: ((CoreDataTrainerViewController.ButtonEvent) -> Void)?
	// Получим CoreData контейнер с базой данных.
	private lazy var persistentContainer: NSPersistentContainer = makeContainer()

	private var mainContext: NSManagedObjectContext {
		persistentContainer.viewContext
	}

	private var backgroundContext: NSManagedObjectContext {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		context.parent = self.mainContext
		return context
	}

	private lazy var createButton: UIButton = makeButtonByEvent(.create)
	private lazy var deleteButton: UIButton = makeButtonByEvent(.delete)
	private lazy var addCompletedButton: UIButton = makeButtonByEvent(.addCompleted)
	private lazy var showCategoriesButton: UIButton = makeButtonByEvent(.showCategories)

	// MARK: - Inits

	deinit {
		print("CoreDataTrainerViewController deinit")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		print("---")
		print(Theme.dateFormatterCD.string(from: Date()))
		if let date = Theme.dateFormatterCD.date(from: "01.01.2023") {
			print(date)
		}
		print("---")

		setup()
		applyStyle()
		setConstraints()

		didSendEventClosure = { [weak self] event in
			switch event {
			case .create:
				print("Создать БД")
				self?.createDB()
			case .delete:
				print("Удалить БД")
				self?.deleteDB()
			case .addCompleted:
				print("Завершить первый трекер")
				self?.addCompleted()
			case .showCategories:
				print("Показать категории")
				self?.showCategories()
			}
		}
	}
}

// MARK: - Core Data

private extension CoreDataTrainerViewController {
	func makeContainer() -> NSPersistentContainer {
		// указываем модель по имени
		let container = NSPersistentContainer(name: "TrackersMOC")
		// добавляем хранилище, в дескрипторе тип и путь к базе
		container.loadPersistentStores { storeDescription, error in
			print("DB = \(storeDescription)")
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}
		return container
	}

	func createDB() {
		let context = mainContext // persistentContainer.viewContext
		let checkRequest = TrackerCategoryCD.fetchRequest()
		do {
			let result = try context.fetch(checkRequest)
			// Если есть данные в базе, то выходим
			if !result.isEmpty { return }
		} catch let error as NSError {
			print("Core Data Error:  \(error), \(error.userInfo)")
			return
		}

		// Данных нет, загружаем
		let repository = TrackerCategoriesStub()

		let categories: [TrackerCategoryCD] = repository.getCategories().map { category in
			let categoryCD = TrackerCategoryCD(context: context)
			categoryCD.categoryID = category.id
			categoryCD.title = category.title
			return categoryCD
		}

		let trackers: [TrackerCD] = repository.getTrackers().map { tracker in
			let trackerCD = TrackerCD(context: context)
			trackerCD.trackerID = tracker.id
			trackerCD.title = tracker.title
			trackerCD.emoji = tracker.emoji
			trackerCD.color = tracker.color
			trackerCD.schedule = tracker.scheduleCD
			return trackerCD
		}

		categories[0].addToTrackers(trackers[0])
		categories[1].addToTrackers(trackers[1])
		categories[2].addToTrackers([trackers[2], trackers[3], trackers[4]])

		let trackerRecordCD = TrackerRecordCD(context: context)
		trackerRecordCD.trackerID = trackers[0].trackerID
		trackerRecordCD.dateString = Theme.dateFormatterCD.string(from: Date())

		trackers[0].addToTrackerRecords(trackerRecordCD)

		do {
			try context.save()
			print("Загрузили категории и трекеры")
		} catch let error as NSError {
			print("Core Data Error:  \(error), \(error.userInfo)")
		}
	}

	func deleteDB() {
		let backgroundContext = self.backgroundContext // persistentContainer.newBackgroundContext()

//		backgroundContext.perform {
//			let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TrackerCD.fetchRequest()
//			let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//			do {
//				try backgroundContext.execute(batchDeleteRequest)
//				try backgroundContext.save()
//				print("Удалили трекеры")
//			} catch {
//				let nserror = error as NSError
//				print("Core Data Error:  \(nserror), \(nserror.userInfo)")
//				return
//			}
//		}

		backgroundContext.performAndWait {
			let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TrackerCategoryCD.fetchRequest()
			let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
			do {
				try backgroundContext.execute(batchDeleteRequest)
				try backgroundContext.save()
				print("Удалили трекеры")
			} catch let error as NSError {
				print("Core Data Error:  \(error), \(error.userInfo)")
			}
		}
	}

	func addCompleted() {
		// получаем первый трекер и завершаем его
		print("Добавить завершение первому трекеру - нет проверки о существовании завершения на эту же дату")

		var trackerID: UUID?
		let context = mainContext // persistentContainer.viewContext
		let request = TrackerCD.fetchRequest()
		request.fetchLimit = 1
		do {
			let result = try context.fetch(request)
			if let id = result[0].trackerID {
				trackerID = id
				print(trackerID ?? "")
			}
		} catch let error as NSError {
			print("Core Data Error:  \(error), \(error.userInfo)")
		}

		if let trackerID = trackerID {
			addCompletedTracker(trackerID: trackerID, date: Date())
		}
	}

	func addCompletedTracker(trackerID: UUID, date: Date) {

		let context = mainContext
		let request = TrackerCD.fetchRequest()
		request.predicate = NSPredicate(
			format: "%K == %@",
			#keyPath(TrackerCD.trackerID),
			trackerID as CVarArg
		)
		let trackerRecordCD = TrackerRecordCD(context: context)// TrackerRecordCD(context: context)
		trackerRecordCD.trackerID = trackerID
		let newDate = Theme.dateFormatterCD.date(from: "01.01.2023")
		trackerRecordCD.dateString = Theme.dateFormatterCD.string(from: newDate!)
		do {
			let result = try context.fetch(request)
			let tracker = result[0]
			tracker.addToTrackerRecords(trackerRecordCD)
			try context.save()
			print("Завершили")
		} catch let error as NSError {
			print("Core Data Error:  \(error), \(error.userInfo)")
		}
	}

	func showCategories() {
		let context = mainContext
		// let request = TrackerCategoryCD.fetchRequest()
		let request = TrackerCD.fetchRequest()

		request.sortDescriptors = [
			NSSortDescriptor(
				keyPath: \TrackerCD.trackerCategory?.title,
				ascending: true
			),
			NSSortDescriptor(
				key: "title",
				ascending: true,
				selector: #selector(NSString.localizedStandardCompare(_:)) // без этого неправильно сортировалось
			)
		]

		let schedulePredicate = NSPredicate(
			format: "schedule contains[c] %@ || schedule == %@",
			"2", // понедельник
			""
		)
		let titleSeachPredicate = NSPredicate(
			format: "title contains[c] %@",
			"баб" // проверяем работу с регистром
		)
		let completedTrackerPredicate = NSPredicate(
			format: "any trackerRecords.dateString == %@",
			"12.06.2023"
		)
		let uncompletedTrackerPredicate = NSPredicate(
			format: "any trackerRecords.dateString != %@ || trackerRecords.@count == 0",
			"12.06.2023"
		)
		let andPredicate = NSCompoundPredicate(
			andPredicateWithSubpredicates: [
//				schedulePredicate,
				titleSeachPredicate,
//				completedTrackerPredicate,
//				uncompletedTrackerPredicate
			]
		)
		request.predicate = andPredicate

		do {
			let result = try context.fetch(request)

			var prevCategory = ""
			for tracker in result {
				let category = tracker.trackerCategory
				if prevCategory != category?.title {
					prevCategory = category?.title ?? ""
					print("Категория: ", prevCategory)
					print("------ трекеры")
				}
				print(
					"--->",
					tracker.title ?? "",
					tracker.trackerRecords?.count ?? 0
				)
			}
		} catch let error as NSError {
			print("Core Data Error:  \(error), \(error.userInfo)")
		}
	}
}

// MARK: - UI
private extension CoreDataTrainerViewController {
	func setup() {
		// определить где может лежать база
		if let directoryLocation = FileManager.default.urls(
			for: .libraryDirectory, in: .userDomainMask
		).last {
			print(directoryLocation)
		}
	}
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = Theme.spacing(usage: .standard)

		[
			createButton,
			deleteButton,
			addCompletedButton,
			showCategoriesButton
		].forEach { item in
			stackView.addArrangedSubview(item)
			item.makeConstraints { make in
				make.size(.init(width: Appearance.buttonSize.width, height: Appearance.buttonSize.height))
			}
		}

		view.addSubview(stackView)
		stackView.makeEqualToSuperviewCenter()
	}
}

// MARK: - UI make
private extension CoreDataTrainerViewController {
	func makeButtonByEvent(_ event: ButtonEvent) -> UIButton {
		let button = UIButton()
		button.titleLabel?.font = Theme.font(style: .callout)
		button.backgroundColor = Theme.color(usage: .accent)
		button.setTitleColor(Theme.color(usage: .attention), for: .normal)
		button.layer.cornerRadius = Theme.size(kind: .cornerRadius)

		switch event {
		case .create:
			button.setTitle("Создать БД", for: .normal)
			button.event = { [weak self] in
				self?.didSendEventClosure?(.create)
			}
		case .delete:
			button.setTitle("Удалить БД", for: .normal)
			button.event = { [weak self] in
				self?.didSendEventClosure?(.delete)
			}
		case .addCompleted:
			button.setTitle("Завершить трекер", for: .normal)
			button.event = { [weak self] in
				self?.didSendEventClosure?(.addCompleted)
			}
		case .showCategories:
			button.setTitle("Показать категории", for: .normal)
			button.event = { [weak self] in
				self?.didSendEventClosure?(.showCategories)
			}
		}

		return button
	}
}

// MARK: - ButtonEvent
private extension CoreDataTrainerViewController {
	enum ButtonEvent {
		case create
		case delete
		case addCompleted
		case showCategories
	}
}

// MARK: - Appearance
private extension CoreDataTrainerViewController {
	enum Appearance {
		static let buttonSize: CGSize = .init(width: 200, height: 50)
	}
}
