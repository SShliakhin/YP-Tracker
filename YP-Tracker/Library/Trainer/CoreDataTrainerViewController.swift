import UIKit
import CoreData

// MARK: - Тренировочный экран

final class CoreDataTrainerViewController: UIViewController {
	private let calendar = Calendar.current
	private var didSendEventClosure: ((CoreDataTrainerViewController.ButtonEvent) -> Void)?

	private var fetchedResultsController = NSFetchedResultsController<TrackerCD>()

	// ====
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
	// ====

	// MARK: - UI
	private lazy var createButton: UIButton = makeButtonByEvent(.create)
	private lazy var deleteButton: UIButton = makeButtonByEvent(.delete)
	private lazy var addCompletedButton: UIButton = makeButtonByEvent(.addCompleted)
	private lazy var showCategoriesButton: UIButton = makeButtonByEvent(.showCategories)
	private lazy var showCategoriesUpdateButton: UIButton = makeButtonByEvent(.showCategoriesUpdate)

	// MARK: - Inits

	deinit {
		print("CoreDataTrainerViewController deinit")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		applyStyle()
		setConstraints()
	}
}

private extension CoreDataTrainerViewController {
	func getSortDescriptor() -> [NSSortDescriptor] {
		return [
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
	}

	func getPredicates(
		date: Date,
		text: String?,
		completed: Bool?
	) -> [NSPredicate] {
		// обязательный предикат
		let schedulePredicate = NSPredicate(
			format: "schedule contains %@ || schedule == %@",
			"\(calendar.component(.weekday, from: date))", // день недели
			""
		)

		var predicates = [schedulePredicate]

		// есть ли поиск по заголовку?
		if let text = text {
			let titleSeachPredicate = NSPredicate(
				format: "title contains[c] %@",
				text.lowercased()
			)
			predicates += [titleSeachPredicate]
		}

		// есть ли фильтр завершения
		switch completed {
		case .none:
			break // здесь не фильтруем
		case let .some(completed):
			let completedUncompletedPredicate: NSPredicate
			let dateString = Theme.dateFormatterCD.string(from: date)
			if completed {
				// оставляем только завершенные
				completedUncompletedPredicate = NSPredicate(
					format: "any trackerRecords.dateString == %@",
					dateString
				)
			} else {
				// оставляем только незавершенные
				completedUncompletedPredicate = NSPredicate(
					format: "any trackerRecords.dateString != %@ || trackerRecords.@count == 0",
					dateString
				)
			}
			predicates += [completedUncompletedPredicate]
		}
		return predicates
	}

	func makeFRC(
		request: NSFetchRequest<TrackerCD>,
		context: NSManagedObjectContext
	) -> NSFetchedResultsController<TrackerCD> {
		let rfc = NSFetchedResultsController(
			fetchRequest: request,
			managedObjectContext: context,
			sectionNameKeyPath: #keyPath(TrackerCD.trackerCategory.title),
			cacheName: nil
		)
		rfc.delegate = self
		try? rfc.performFetch()

		return rfc
	}

	func getCategories(
		date: Date,
		text: String?,
		completed: Bool?
	) {
		// - подготовить новый запрос
		let request = TrackerCD.fetchRequest()
		// сортировка
		request.sortDescriptors = getSortDescriptor()
		// выборка
		let predicates = getPredicates(
			date: date,
			text: text,
			completed: completed
		)
		request.predicate = NSCompoundPredicate(
			andPredicateWithSubpredicates: predicates
		)
		// - создать и выполнить новый frc
		fetchedResultsController = makeFRC(
			request: request,
			context: mainContext
		)
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
		let backgroundContext = self.backgroundContext

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
		let isOK = completeUncompleteTrackerByPlace(section: 0, row: 0, date: Date())
	}

	func completeUncompleteTrackerByPlace(section: Int, row: Int, date: Date) -> Bool {
		// проверка на наличие данных
		guard fetchedResultsController.sections != nil else { return false }

		let indexPath: IndexPath = .init(row: row, section: section)
		let object = fetchedResultsController.object(at: indexPath)
		// удалять или добавлять?

		let dateString = Theme.dateFormatterCD.string(from: date)
		// попытаемся найти с этой датой
		if let records = object.trackerRecords as? Set<TrackerRecordCD>,
		   let record = records.first(where: { $0.dateString == dateString }) {
			// удалить
			object.removeFromTrackerRecords(record)
		} else {
			// добавить
			let newRecord = TrackerRecordCD(context: mainContext)
			newRecord.dateString = dateString
			newRecord.trackerID = object.trackerID

			object.addToTrackerRecords(newRecord)
		}
		return true
	}

	func show(date: Date) {
		// проверка на наличие данных
		guard let sections = fetchedResultsController.sections else { return }

		let dateString = Theme.dateFormatterCD.string(from: date)
		print("--------- Показываем на дату: \(dateString)")

		for section in sections {
			print("Категория: ", section.name)
			guard let trackers = section.objects as? [TrackerCD] else { continue }
			for tracker in trackers {
				print(tracker.title ?? "", tracker.trackerRecords?.count ?? 0)
				// определить завершенный ли трекер на выбранный день
				if let records = tracker.trackerRecords as? Set<TrackerRecordCD> {
					let dates = records.map { $0.dateString }
					print(dates.contains(dateString))
				}
			}
			print("---------------")
		}
		print("xxxxxxxxxxxxxxxx")

		showTrackers()
	}

	func showTrackers() {
		guard let trackers = fetchedResultsController.fetchedObjects else { return }
		for tracker in trackers {
			print("Tr:")
			print(
				tracker.title ?? "",
				tracker.color ?? "",
				tracker.emoji ?? "",
				tracker.trackerID ?? ""
			)
		}
	}

	func showCategories() {
		let date = Date()
		getCategories(date: date, text: nil, completed: nil)
		show(date: date)
	}

	func showCategoriesUpdate() {
		let date = Date()
		getCategories(date: date, text: nil, completed: true)
		show(date: date)
	}
}

// MARK: - UI
private extension CoreDataTrainerViewController {
	func setup() {
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
			case .showCategoriesUpdate:
				print("Показать новые категории")
				self?.showCategoriesUpdate()
			}
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
			showCategoriesButton,
			showCategoriesUpdateButton
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
		case .showCategoriesUpdate:
			button.setTitle("Показать новые категории", for: .normal)
			button.event = { [weak self] in
				self?.didSendEventClosure?(.showCategoriesUpdate)
			}
		}

		return button
	}
}

extension CoreDataTrainerViewController: NSFetchedResultsControllerDelegate {}

// MARK: - ButtonEvent
private extension CoreDataTrainerViewController {
	enum ButtonEvent {
		case create
		case delete
		case addCompleted
		case showCategories
		case showCategoriesUpdate
	}
}

// MARK: - Appearance
private extension CoreDataTrainerViewController {
	enum Appearance {
		static let buttonSize: CGSize = .init(width: 200, height: 50)
	}
}
