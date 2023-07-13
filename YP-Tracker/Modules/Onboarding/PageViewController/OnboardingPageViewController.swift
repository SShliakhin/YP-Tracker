import UIKit

protocol ViewControllerWithImageView: UIViewController {
	var imageView: UIImageView { get set }
}

final class OnboardingPageViewController: UIViewController, ViewControllerWithImageView {
	private let page: OnboardingPage

	lazy var imageView: UIImageView = makeImageView()
	private lazy var textLabel: UILabel = makeLabel()

	// MARK: - Inits

	init(page: OnboardingPage) {
		self.page = page
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("OnboardingPageViewController deinit")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setConstraints()
	}
}

// MARK: - UI
private extension OnboardingPageViewController {
	func setConstraints() {
		[
			imageView,
			textLabel
		].forEach { view.addSubview($0) }

		imageView.makeEqualToSuperview()
		textLabel.makeEqualToSuperviewCenter(
			insets: .init(top: Appearance.centerIndent)
		)
	}
}

// MARK: - UI make
private extension OnboardingPageViewController {
	func makeImageView() -> UIImageView {
		let imageView = UIImageView(image: page.imageValue)
		imageView.contentMode = .scaleAspectFill
		return imageView
	}
	func makeLabel() -> UILabel {
		let label = UILabel()
		label.text = page.textValue
		label.textColor = Theme.color(usage: .main)
		label.font = Theme.font(style: .title1)
		label.textAlignment = .center
		label.numberOfLines = .zero
		return label
	}
}

// MARK: - Appearance
private extension OnboardingPageViewController {
	enum Appearance {
		static let centerIndent = UIScreen.main.bounds.height / 100 * 7.88
	}
}
