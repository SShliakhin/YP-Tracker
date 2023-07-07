import UIKit

final class OnboardingViewController: UIViewController {
	private let interactor: IOnboardingInteractor
	private let pageViewController: UIPageViewController

	private lazy var actionButton: UIButton = makeActionButton()

	// MARK: - Inits

	init(interactor: IOnboardingInteractor, pageViewController: UIPageViewController) {
		self.interactor = interactor
		self.pageViewController = pageViewController
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("OnboardingViewController deinit")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		applyStyle()
		setConstraints()
	}
}

// MARK: - UI
private extension OnboardingViewController {
	func setup() {
		addChild(pageViewController)
		view.addSubview(pageViewController.view)
		pageViewController.didMove(toParent: self)
	}
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		[
			actionButton
		].forEach { view.addSubview($0) }

		actionButton.makeConstraints { make in
			[
				make.leadingAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.leadingAnchor,
					constant: Theme.spacing(usage: .constant20)
				),
				make.trailingAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.trailingAnchor,
					constant: -Theme.spacing(usage: .constant20)
				),
				make.bottomAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.bottomAnchor,
					constant: -Appearance.buttonBottomAnchorConstant
				),
				make.heightAnchor.constraint(
					equalToConstant: Theme.dimension(kind: .smallHeight)
				)
			]
		}
	}
}

// MARK: - UI make
private extension OnboardingViewController {
	func makeActionButton() -> UIButton {
		let button = UIButton()

		button.setTitle(Appearance.buttonTitle, for: .normal)
		button.setTitleColor(Theme.color(usage: .white), for: .normal)
		button.titleLabel?.font = Theme.font(style: .callout)
		button.backgroundColor = Theme.color(usage: .black)
		button.layer.cornerRadius = Theme.dimension(kind: .cornerRadius)

		button.event = { [weak self] in
			self?.interactor.didUserDo(request: .finishOnboarding)
		}

		return button
	}
}

// MARK: - Appearance
private extension OnboardingViewController {
	enum Appearance {
		static let buttonTitle = "Вот это технологии!"
		static let buttonBottomAnchorConstant: CGFloat = 50
	}
}
