import UIKit
final class TabbarCoordinator: BaseCoordinator {
	private let factory: IModuleFactory
	private let coordinatorFactory: ICoordinatorFactory
	private let router: IRouter

	var finishFlow: (() -> Void)?

	private var tabbarController: UITabBarController?

	init(router: IRouter, factory: IModuleFactory, coordinatorFactory: ICoordinatorFactory) {
		self.router = router
		self.factory = factory
		self.coordinatorFactory = coordinatorFactory
	}

	override func start() {
		showTabbarModule()
	}

	deinit {
		print("TabBarCoordinator deinit")
	}
}

// MARK: - run Flows
private extension TabbarCoordinator {
	func runTrackersFlowInTab(navCotroller: UINavigationController) {
		let coordinator = coordinatorFactory.makeTrackersCoordinator(navController: navCotroller)
		coordinator.finishFlow = { [weak self, weak coordinator] in
			self?.router.dismissModule()
			self?.removeDependency(coordinator)
			self?.finishFlow?()
		}
		addDependency(coordinator)
		coordinator.start()
	}
}

// MARK: - show Modules
private extension TabbarCoordinator {
	func showTabbarModule() {
		let module = factory.makeTabbarModule()
		let moduleVC = module as? TabbarViewController
		moduleVC?.didSendEventClosure = { event in
			let action: (() -> Void)
			switch event {
			case let .trackers(navController):
				action = { [unowned self] in
					if navController.viewControllers.isEmpty {
						self.runTrackersFlowInTab(navCotroller: navController)
					}
				}
			case let .statistics(navController):
				action = { [unowned self] in
					if navController.viewControllers.isEmpty {
						self.showStatisticsModuleInTab(router: navController)
					}
				}
			case let .viewDidLoad(navController):
				action = { [unowned self] in
					if navController.viewControllers.isEmpty {
						self.runTrackersFlowInTab(navCotroller: navController)
					}
				}
			}
			return action
		}
		router.setRootModule(module, hideBar: true)

		if let controller = moduleVC?.customizableViewControllers?.first as? UINavigationController {
			moduleVC?.didSendEventClosure?(.viewDidLoad(controller))()
		}
		tabbarController = moduleVC
	}

	func showStatisticsModuleInTab(router: UINavigationController) {
		let module = factory.makeStatisticsModule()
		router.pushViewController(module, animated: true)
	}
}
