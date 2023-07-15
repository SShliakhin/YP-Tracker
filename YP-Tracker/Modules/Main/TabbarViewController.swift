import UIKit

final class TabbarViewController: UITabBarController {

	var didSendEventClosure: ((Event) -> (() -> Void))?

	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		applyStyle()
	}
}

// MARK: - UITabBarControllerDelegate

extension TabbarViewController: UITabBarControllerDelegate {
	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		guard let controller = viewControllers?[selectedIndex] as? UINavigationController else { return }

		if selectedIndex == 0 {
			didSendEventClosure?(.trackers(controller))()
		} else if selectedIndex == 1 {
			didSendEventClosure?(.statistics(controller))()
		}
	}
}

extension TabbarViewController {
	enum Event {
		case trackers(UINavigationController)
		case statistics(UINavigationController)
		case viewDidLoad(UINavigationController)
	}
}

private extension TabbarViewController {
	func setup() {
		delegate = self

		let pages: [TabbarPage] = [.trackers, .statistics]
			.sorted(by: { $0.pageOrderNumber() < $1.pageOrderNumber() })
		let controllers: [UINavigationController] = pages.map { getTabController($0) }

		prepareTabbarController(withTabControllers: controllers)

		if let controller = customizableViewControllers?[selectedIndex] as? UINavigationController {
			didSendEventClosure?(.viewDidLoad(controller))()
		}
	}

	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}

	func getTabController(_ page: TabbarPage) -> UINavigationController {
		let navController = UINavigationController()

		navController.tabBarItem = UITabBarItem(
			title: page.pageTitleValue(),
			image: page.pageIconValue(),
			tag: page.pageOrderNumber()
		)

		navController.navigationBar.prefersLargeTitles = true

		navController.navigationBar.standardAppearance.largeTitleTextAttributes = [
			NSAttributedString.Key.foregroundColor: Theme.color(usage: .black),
			NSAttributedString.Key.font: Theme.font(style: .largeTitle)
		]

		return navController
	}

	func prepareTabbarController(withTabControllers tabControllers: [UIViewController]) {
		setViewControllers(tabControllers, animated: true)
		selectedIndex = TabbarPage.trackers.pageOrderNumber()

		let tabBarItemsAppearance = UITabBarItemAppearance()
		tabBarItemsAppearance.normal.titleTextAttributes = [
			NSAttributedString.Key.font: Theme.font(style: .caption2)
		]

		let tabBarAppearance = UITabBarAppearance()
		tabBarAppearance.backgroundColor = Theme.color(usage: .white)
		tabBarAppearance.stackedLayoutAppearance = tabBarItemsAppearance

		tabBar.standardAppearance = tabBarAppearance

		if #available(iOS 15.0, *) {
			tabBar.scrollEdgeAppearance = tabBarAppearance
		}

		tabBar.tintColor = Theme.color(usage: .accent)

		tabBar.isTranslucent = false
		tabBar.clipsToBounds = true

		let navBarAppearance = UINavigationBarAppearance()
		navBarAppearance.configureWithTransparentBackground()
		navBarAppearance.backgroundColor = Theme.color(usage: .white)
		UINavigationBar.appearance().standardAppearance = navBarAppearance
		UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
	}
}

// MARK: - Appearance
private extension TabbarViewController {
	enum Appearance {
		static let trackersTabTitle = NSLocalizedString(
			"trackers.tabbarItem.title",
			comment: "Заголовок для элемента таббар: Трекеры"
		)
		static let statisticsTabTitle = NSLocalizedString(
			"statistics.tabbarItem.title",
			comment: "Заголовок для элемента таббар: Статистика"
		)
	}

	// swiftlint:disable numbers_smell
	enum TabbarPage: Int {
		case trackers
		case statistics

		init?(index: Int) {
			switch index {
			case 0:
				self = .trackers
			case 1:
				self = .statistics
			default:
				return nil
			}
		}

		func pageOrderNumber() -> Int {
			switch self {
			case .trackers:
				return 0
			case .statistics:
				return 1
			}
		}
		func pageTitleValue() -> String {
			switch self {
			case .trackers:
				return Appearance.trackersTabTitle
			case .statistics:
				return Appearance.statisticsTabTitle
			}
		}
		func pageIconValue() -> UIImage {
			switch self {
			case .trackers:
				return Theme.image(kind: .tabTrackerIcon)
			case .statistics:
				return Theme.image(kind: .tabStatsIcon)
			}
		}

		// Add tab icon selected / deselected color
		// etc
	}
	// swiftlint:enable numbers_smell
}
