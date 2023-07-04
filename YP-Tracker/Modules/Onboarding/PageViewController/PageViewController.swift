import UIKit

final class PageViewController: UIPageViewController {

	private var leftPageScroll: Int?
	private var currentPageScroll: Int?
	private var rightPageScroll: Int?

	private var pages: [UIViewController] = []

	var currentIndex: Int {
		if
			let first = self.viewControllers?.first,
			let index = pages.firstIndex(of: first) {
			return index
		}
		return .zero
	}

	// MARK: - Inits

	init(viewControllers: [UIViewController]? = nil) {
		super.init(
			transitionStyle: .scroll,
			navigationOrientation: .horizontal,
			options: [:]
		)
		if let viewControllers = viewControllers {
			pages = viewControllers
		}
		setup()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("PageViewController deinit")
	}

	// MARK: - Life cycle

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		for view in self.view.subviews {
			if view is UIScrollView {
				view.frame = UIScreen.main.bounds
			} else if view is UIPageControl {
				view.backgroundColor = .clear
				view.frame.origin.y = self.view.bounds.size.height - view.bounds.height - Appearance.pageControlYMinusConstant

				(view as? UIPageControl)?.currentPageIndicatorTintColor = Theme.color(usage: .black)
				(view as? UIPageControl)?.pageIndicatorTintColor = Theme.color(usage: .gray)
			}
		}
	}
}

private extension PageViewController {
	func setup() {
		guard
			let scrollview = view.subviews.first(
				where: { $0 is UIScrollView }
			) as? UIScrollView else { return }

		// делаем PageViewController делегатом прокрутки
		scrollview.delegate = self

		dataSource = self
		delegate = self

		if pages.isEmpty {
			createPages()
		}

		if let firstViewController = pages.first {
			setViewControllers(
				[firstViewController],
				direction: .forward,
				animated: true,
				completion: nil
			)
		}
	}

	func createPages() {
		for page in OnboardingPage.allCases {
			pages.append(OnboardingPageViewController(page: page))
		}
	}
}

// MARK: - UIPageViewControllerDataSource

extension PageViewController: UIPageViewControllerDataSource {
	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerBefore viewController: UIViewController
	) -> UIViewController? {
		guard let currentPageIndex = pages.firstIndex(of: viewController) else {
			return nil
		}

		let previousIndex = currentPageIndex - 1

		guard
			previousIndex >= 0,
			pages.count > previousIndex
		else {
			return nil
		}

		return pages[previousIndex]
	}

	func pageViewController(
		_ pageViewController: UIPageViewController,
		viewControllerAfter viewController: UIViewController
	) -> UIViewController? {
		guard let currentPageIndex = pages.firstIndex(of: viewController) else {
			return nil
		}

		let nextIndex = currentPageIndex + 1

		// зациклим вправо
		if pages.count == nextIndex {
			return pages.first
		}

		guard pages.count > nextIndex else {
			return nil
		}

		return pages[nextIndex]
	}

	// MARK: - UIPageControl

	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return pages.count
	}

	func presentationIndex(for pageViewController: UIPageViewController) -> Int {
		return currentIndex
	}
}

// MARK: UIPageViewControllerDelegate

extension PageViewController: UIPageViewControllerDelegate {}

// MARK: UIScrollViewDelegate

extension PageViewController: UIScrollViewDelegate {

	// позволяет узнать какая страница является текущей, предыдушей и следующей
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		setVarsForScroll()
	}

	private func setVarsForScroll() {
		leftPageScroll = mod((currentIndex - 1), pages.count)
		currentPageScroll = currentIndex
		rightPageScroll = mod((currentIndex + 1), pages.count)
	}

	private func mod(_ new: Int, _ all: Int) -> Int {
		precondition(all > 0, "modulus must be positive")
		let result = new % all
		return result >= 0 ? result : result + all
	}

	// вся магия здесь
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
		let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
		let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset

		guard let currentPageScroll = currentPageScroll else { return }

		if percentageHorizontalOffset < 0.5 {
			guard let leftPageScroll = leftPageScroll else { return }
			if let prevVC = pages[leftPageScroll] as? ViewControllerWithImageView {
				prevVC.imageView.transform = CGAffineTransform(
					scaleX: (1 - percentageHorizontalOffset),
					y: (1 - percentageHorizontalOffset)
				)
			}
		}

		if percentageHorizontalOffset > 0.5 {
			guard let rightPageScroll = rightPageScroll else { return }
			if let prevVC = pages[currentPageScroll] as? ViewControllerWithImageView {
				prevVC.imageView.transform = CGAffineTransform(
					scaleX: abs(0.75 - percentageHorizontalOffset) / 0.25,
					y: abs(0.75 - percentageHorizontalOffset) / 0.25
				)
			}

			if let nextVC = pages[rightPageScroll] as? ViewControllerWithImageView {
				nextVC.imageView.transform = CGAffineTransform(
					scaleX: percentageHorizontalOffset,
					y: percentageHorizontalOffset
				)
			}
		}
	}
}

// MARK: - Appearance
private extension PageViewController {
	enum Appearance {
		static let pageControlYMinusConstant: CGFloat = 168
	}
}
