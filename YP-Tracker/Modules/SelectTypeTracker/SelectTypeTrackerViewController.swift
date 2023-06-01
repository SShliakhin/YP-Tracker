import UIKit

final class SelectTypeTrackerViewController: UIViewController {
	let interactor: ISelectTypeTrackerInteractor

	private lazy var habitButton: UIButton = makeButtonByTrackerType(.habit)
	private lazy var eventButton: UIButton = makeButtonByTrackerType(.event)

	// MARK: - Inits

	init(interactor: ISelectTypeTrackerInteractor) {
		self.interactor = interactor
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("SelectTypeTrackerViewController deinit")
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
private extension SelectTypeTrackerViewController {
	func setup() {
		navigationController?.navigationBar.prefersLargeTitles = false
		navigationController?.navigationBar.standardAppearance.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: Theme.color(usage: .black),
			NSAttributedString.Key.font: Theme.font(style: .callout)
		]
	}
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = Theme.spacing(usage: .standard2)
		stack.alignment = .center

		[
			habitButton,
			eventButton
		].forEach { stack.addArrangedSubview($0) }

		habitButton.makeConstraints { make in
			[
				make.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: Theme.spacing(usage: .standardHalf)),
				make.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: -Theme.spacing(usage: .standardHalf)),
				make.heightAnchor.constraint(equalToConstant: Theme.size(kind: .buttonHeight))
			]
		}
		eventButton.makeConstraints { make in
			[
				make.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: Theme.spacing(usage: .standardHalf)),
				make.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: -Theme.spacing(usage: .standardHalf)),
				make.heightAnchor.constraint(equalToConstant: Theme.size(kind: .buttonHeight))
			]
		}

		view.addSubview(stack)
		stack.makeConstraints { make in
			[
				make.centerYAnchor.constraint(equalTo: view.centerYAnchor),
				make.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.spacing(usage: .standard2)),
				make.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.spacing(usage: .standard2))
			]
		}
	}
}

// MARK: - UI make
private extension SelectTypeTrackerViewController {
	func makeButtonByTrackerType(_ type: Tracker.TrackerType) -> UIButton {
		let button = UIButton()

		button.setTitle(type.description, for: .normal)
		button.setTitleColor(Theme.color(usage: .white), for: .normal)
		button.titleLabel?.font = Theme.font(style: .callout)
		button.backgroundColor = Theme.color(usage: .black)
		button.layer.cornerRadius = Theme.size(kind: .cornerRadius)

		button.event = { [weak self] in
			self?.interactor.didUserDo(request: .selectType(type))
		}

		return button
	}
}
