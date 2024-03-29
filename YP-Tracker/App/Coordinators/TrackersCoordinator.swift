import UIKit

final class TrackersCoordinator: BaseCoordinator {
	private let factory: IModuleFactory
	private let coordinatorFactory: ICoordinatorFactory
	private let router: Router

	private var onUpdateFilter: ((TrackerFilter) -> Void)?
	private var onUpdateTrackers: (() -> Void)?

	var finishFlow: (() -> Void)?

	init(router: Router, factory: IModuleFactory, coordinatorFactory: ICoordinatorFactory) {
		self.router = router
		self.factory = factory
		self.coordinatorFactory = coordinatorFactory
	}

	override func start() {
		showTrackersModule()
	}

	deinit {
		print("TrackersCoordinator deinit")
	}
}

// MARK: - run Flows
private extension TrackersCoordinator {
	func runCreateNewTrackerFlow(trackerType: Tracker.TrackerType) {
		let coordinator = coordinatorFactory.makeCreateEditTrackerCoordinator(
			router: router,
			trackerAction: .new(trackerType)
		)
		coordinator.finishFlow = { [weak self, weak coordinator] in
			self?.removeDependency(coordinator)
			self?.onUpdateTrackers?()
		}
		addDependency(coordinator)
		coordinator.start()
	}

	func runEditTrackerFlow(trackerID: UUID) {
		let coordinator = coordinatorFactory.makeCreateEditTrackerCoordinator(
			router: router,
			trackerAction: .edit(trackerID)
		)
		coordinator.finishFlow = { [weak self, weak coordinator] in
			self?.removeDependency(coordinator)
			self?.onUpdateTrackers?()
		}
		addDependency(coordinator)
		coordinator.start()
	}
}

// MARK: - show Modules
private extension TrackersCoordinator {
	func showTrackersModule() {
		let (module, moduleInteractor) = factory.makeTrackersModule()

		onUpdateFilter = { [weak moduleInteractor] filter in
			moduleInteractor?.didUserDo(request: .newFilter(filter))
		}
		onUpdateTrackers = { [weak moduleInteractor] in
			moduleInteractor?.viewIsReady()
		}
		moduleInteractor.didSendEventClosure = { [weak self] event in
			switch event {
			case .addTracker:
				self?.showSelectTypeTrackerModule()
			case let .editTracker(trackerID):
				self?.runEditTrackerFlow(trackerID: trackerID)
			case let .selectFilter(filter):
				self?.showSelectFilterModule(currentFilter: filter)
			}
		}
		module.title = ScreensTitles.titleTrackersVC
		router.setRootModule(module)
	}

	func showSelectFilterModule(currentFilter: TrackerFilter) {
		let (module, moduleInteractor) = factory.makeYPModule(
			trackerAction: .selectFilter(currentFilter)
		)
		moduleInteractor.didSendEventClosure = { [weak self] event in
			if case let .selectFilter(filter) = event {
				self?.router.dismissModule()
				self?.onUpdateFilter?(filter)
			}
		}
		module.title = ScreensTitles.titleFiltersVC
		router.present(UINavigationController(rootViewController: module))
	}

	func showSelectTypeTrackerModule() {
		let (module, moduleInteractor) = factory.makeSelectTypeTrackerModule()
		moduleInteractor.didSendEventClosure = { [weak self] event in
			switch event {
			case let .selectType(type):
				self?.router.dismissModule()
				self?.runCreateNewTrackerFlow(trackerType: type)
			}
		}
		module.title = ScreensTitles.titleSelectTrackerTypeVC
		router.present(UINavigationController(rootViewController: module))
	}
}
