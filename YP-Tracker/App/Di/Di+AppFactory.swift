import UIKit

// MARK: - AppFactory

protocol IAppFactory {
	func makeKeyWindowWithCoordinator(scene: UIWindowScene) -> (UIWindow, ICoordinator)
	func makeKeyWindow(scene: UIWindowScene) -> UIWindow
}

extension Di: IAppFactory {
	func makeKeyWindowWithCoordinator(scene: UIWindowScene) -> (UIWindow, ICoordinator) {
		let window = UIWindow(windowScene: scene)
		window.makeKeyAndVisible()

		let navigationController = UINavigationController()
		navigationController.navigationBar.prefersLargeTitles = true

		let router = Router(rootController: navigationController)
		let coordinator = makeApplicationCoordinator(router: router)

		window.rootViewController = navigationController
		return (window, coordinator)
	}

	func makeKeyWindow(scene: UIWindowScene) -> UIWindow {
		let window = UIWindow(windowScene: scene)
		window.makeKeyAndVisible()

		window.rootViewController = makeStartModule()
		return window
	}
}
