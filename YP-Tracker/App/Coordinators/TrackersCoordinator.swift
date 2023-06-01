import UIKit

final class TrackersCoordinator: BaseCoordinator {
	private let factory: IModuleFactory
	private let coordinatorFactory: ICoordinatorFactory
	private let router: IRouter

	private var onUpdateFilter: ((TrackerFilter) -> Void)?
	private var onUpdateTrackers: (() -> Void)?

	var finishFlow: (() -> Void)?

	init(router: IRouter, factory: IModuleFactory, coordinatorFactory: ICoordinatorFactory) {
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
			case let .selectFilter(filter):
				self?.showSelectFilterModule(currentFilter: filter)
			}
		}

		router.setRootModule(module)
	}

	func showSelectFilterModule(currentFilter: TrackerFilter) {
		let module = factory.makeYPModule(
			trackerAction: .selectFilter(currentFilter)
		)
		let moduleVC = module as? YPViewController
		moduleVC?.didSendEventClosure = { [weak self] event in
			if case let .didSelectFilter(filter) = event {
				self?.router.dismissModule()
				self?.onUpdateFilter?(filter)
			}
		}
		moduleVC?.title = Appearance.titleFiltersVC
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
		module.title = Appearance.titleSelectTrackerTypeVC
		router.present(UINavigationController(rootViewController: module))
	}
}

private extension TrackersCoordinator {
	enum Appearance {
		static let titleFiltersVC = "Фильтры"
		static let titleSelectTrackerTypeVC = "Создание трекера"
	}
}
