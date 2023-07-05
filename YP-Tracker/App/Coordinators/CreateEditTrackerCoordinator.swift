import UIKit

final class CreateEditTrackerCoordinator: BaseCoordinator {
	private let factory: IModuleFactory
	private let router: Router
	private let trackerAction: Tracker.Action

	private var onUpdateCategory: ((UUID, String) -> Void)?
	private var onUpdateSchedule: (([Int: Bool]) -> Void)?

	private var onUpdateCategories: (() -> Void)?

	var finishFlow: (() -> Void)?

	init(router: Router, factory: IModuleFactory, trackerAction: Tracker.Action) {
		self.router = router
		self.factory = factory
		self.trackerAction = trackerAction
	}

	override func start() {
		showCreateEditTrackerModule()
	}

	deinit {
		print("CreateEditTrackerCoordinator deinit")
	}
}

// MARK: - show Modules
private extension CreateEditTrackerCoordinator {
	func showCreateEditTrackerModule() {
		let (module, moduleInteractor) = factory.makeCreateEditTrackerModule(trackerAction: trackerAction)

		onUpdateCategory = { [weak moduleInteractor] id, title in
			moduleInteractor?.didUserDo(request: .newCategory(id, title))
		}
		onUpdateSchedule = { [weak moduleInteractor] schedule in
			moduleInteractor?.didUserDo(request: .newSchedule(schedule))
		}
		moduleInteractor.didSendEventClosure = { [weak self, weak module] event in
			switch event {
			case let .selectCategory(currentID):
				// Study MVVM
				// self?.showSelectCategoryModule(
				self?.showSelectCategoryModuleMVVM(
					currentCategory: currentID,
					router: module
				)
			case let .selectSchedule(currentSchedule):
				self?.showSelectScheduleModule(
					currentSchedule: currentSchedule,
					router: module
				)
			case .save, .cancel:
				self?.router.dismissModule()
				self?.finishFlow?()
			}
		}

		module.title = makeTitle()
		router.present(
			UINavigationController(rootViewController: module),
			animated: true
		) { [weak self] in
			self?.finishFlow?()
		}
	}

	func showSelectCategoryModule(currentCategory: UUID?, router: UIViewController?) {
		let (module, moduleInteractor) = factory.makeYPModule(
			trackerAction: .selectCategory(currentCategory)
		)

		onUpdateCategories = { [weak moduleInteractor] in
			moduleInteractor?.didUserDo(request: .updateView)
		}
		moduleInteractor.didSendEventClosure = { [weak self, weak module] event in
			if case let .selectCategory(id, title) = event {
				module?.dismiss(animated: true)
				self?.onUpdateCategory?(id, title)
			}
			if case .addCategory = event {
				self?.showAddCategoryModule(router: module)
			}
		}
		module.title = Appearance.titleCategoryVC
		router?.present(UINavigationController(rootViewController: module), animated: true)
	}

	func showSelectCategoryModuleMVVM(currentCategory: UUID?, router: UIViewController?) {
		let (module, viewModel) = factory.makeCategoriesListModuleMVVM(
			trackerAction: .selectCategory(currentCategory)
		)

		onUpdateCategories = { [weak viewModel] in
			viewModel?.didUserDo(request: .updateView)
		}
		viewModel.didSendEventClosure = { [weak self, weak module] event in
			if case let .selectCategory(id, title) = event {
				module?.dismiss(animated: true)
				self?.onUpdateCategory?(id, title)
			}
			if case .addCategory = event {
				self?.showAddCategoryModule(router: module)
			}
		}
		module.title = Appearance.titleCategoryVC
		router?.present(UINavigationController(rootViewController: module), animated: true)
	}

	func showSelectScheduleModule(currentSchedule: [Int: Bool], router: UIViewController?) {
		let (module, moduleInteractor) = factory.makeYPModule(
			trackerAction: .selectSchedule(currentSchedule)
		)
		moduleInteractor.didSendEventClosure = { [weak self, weak module] event in
			if case let .selectSchedule(schedule) = event {
				module?.dismiss(animated: true)
				self?.onUpdateSchedule?(schedule)
			}
		}
		module.title = Appearance.titleScheduleVC
		router?.present(UINavigationController(rootViewController: module), animated: true)
	}

	func showAddCategoryModule(router: UIViewController?) {
		let (module, moduleInteractor) = factory.makeCreateEditCategoryModule(trackerAction: .addCategory)
		moduleInteractor.didSendEventClosure = { [weak self, weak module] event in
			if case .save = event {
				module?.dismiss(animated: true)
				self?.onUpdateCategories?()
			}
		}
		module.title = Appearance.titleAddCategoryVC
		router?.present(UINavigationController(rootViewController: module), animated: true)
	}
}

private extension CreateEditTrackerCoordinator {
	enum Appearance {
		static let titleHabitVC = "Новая привычка"
		static let titleEventVC = "Новое нерегулярное событие"
		static let titleCategoryVC = "Категория"
		static let titleScheduleVC = "Расписание"
		static let titleAddCategoryVC = "Новая категория"
		static let titleEditTrackerVC = "Редактирование привычки"
		static let defaultTitle = "Создание/редактирование привычки"
	}

	func makeTitle() -> String {
		if case let Tracker.Action.new(trackerType) = trackerAction {
			if trackerType == .habit {
				return Appearance.titleHabitVC
			} else {
				return Appearance.titleEventVC
			}
		}
		if case Tracker.Action.edit = trackerAction {
			return Appearance.titleEditTrackerVC
		}
		return Appearance.defaultTitle
	}
}
