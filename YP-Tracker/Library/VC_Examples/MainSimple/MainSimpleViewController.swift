import UIKit

final class MainSimpleViewController: UIViewController {
	var didSendEventClosure: ((MainSimpleViewController.Event) -> (() -> Void))?

	private lazy var onboardingButton: UIButton = makeButtonByEvent(.onboarding)
	private lazy var tabButton: UIButton = makeButtonByEvent(.tab)
	private lazy var aboutButton: UIButton = makeButtonByEvent(.about)

	// MARK: - Inits

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("MainSimpleViewController deinit")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		applyStyle()
		setConstraints()
	}
}

// MARK: - Action
extension MainSimpleViewController {
	enum Event {
		case onboarding
		case tab
		case about

		func menuTitleValue() -> String {
			switch self {
			case .onboarding:
				return "Onboarding screen"
			case .tab:
				return "Tab screen"
			case .about:
				return "About screen"
			}
		}

		func menuIconValue() -> UIImage {
			let image: UIImage
			switch self {
			case .onboarding:
				image = .actions
			case .tab:
				image = .add
			case .about:
				image = .remove // .checkmark
			}
			return image
		}
	}
}

// MARK: - UI
private extension MainSimpleViewController {
	func setup() {
		navigationController?.navigationBar.prefersLargeTitles = true
	}
	func applyStyle() {
		title = Appearance.title
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = Theme.spacing(usage: .standard2)
		stack.alignment = .leading

		[
			onboardingButton,
			tabButton,
			aboutButton
		].forEach { stack.addArrangedSubview($0) }

		view.addSubview(stack)
		stack.makeEqualToSuperviewCenter()
	}
}

// MARK: - UI make
private extension MainSimpleViewController {
	func makeButtonByEvent(_ event: Event) -> UIButton {
		let button = UIButton()

		button.setImage(event.menuIconValue(), for: .normal)
		button.setTitle(event.menuTitleValue(), for: .normal)
		button.setTitleColor(Theme.color(usage: .main), for: .normal)

		button.event = didSendEventClosure?(event)

		return button
	}
}

// MARK: - Appearance
private extension MainSimpleViewController {
	enum Appearance {
		static let title = "Simple main"
	}
}

// MARK: - Button event

// extension UIButton {
//	private enum AssociatedKeys {
//		static var event = "event"
//	}
//
//	var event: (() -> Void)? {
//		get {
//			return objc_getAssociatedObject(self, &AssociatedKeys.event) as? () -> Void
//		}
//		set {
//			objc_setAssociatedObject(self, &AssociatedKeys.event, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//			addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
//		}
//	}
//
//	@objc private func onButtonTapped() {
//		event?()
//	}
// }
