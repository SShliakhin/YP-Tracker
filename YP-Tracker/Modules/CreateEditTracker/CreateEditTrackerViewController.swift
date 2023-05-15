import UIKit

final class CreateEditTrackerViewController: UIViewController {
	var didSendEventClosure: ((Tracker.Action) -> (() -> Void))?

	private let trackerAction: Tracker.Action
	private var trackerCategory: UUID?
	private var trackerSchedule: [Int: Bool] = [:]

	private lazy var titleTextField: UITextField = makeTitleTextField()
	private lazy var scheduleSelectButton: UIButton = makeScheduleSelectButton()
	private lazy var categorySelectButton: UIButton = makeCategorySelectButton()

	private let emojis = Theme.Constansts.emojis

	private lazy var createButton: UIButton = makeCreateButton()
	private lazy var cancelButton: UIButton = makeCancelButton()

	// MARK: - Inits

	init(trackerAction: Tracker.Action) {
		self.trackerAction = trackerAction
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("CreateEditTrackerViewController deinit")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		applyStyle()
		setupConstraints()
	}
}

// MARK: - UITextFieldDelegate

extension CreateEditTrackerViewController: UITextFieldDelegate {}

// MARK: - UI
private extension CreateEditTrackerViewController {
	func setup() {
		navigationController?.navigationBar.prefersLargeTitles = false
		navigationController?.navigationBar.standardAppearance.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: Theme.color(usage: .black),
			NSAttributedString.Key.font: Theme.font(style: .callout)
		]
	}
	func applyStyle() {
		title = Appearance.titleNew
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setupConstraints() {}
}

// MARK: - UI make
private extension CreateEditTrackerViewController {
	func makeTitleTextField() -> UITextField {
		let textField = UITextField()
		textField.placeholder = Appearance.textFieldPlaceholder
		textField.backgroundColor = Theme.color(usage: .background)
		textField.textColor = Theme.color(usage: .main)
		textField.font = Theme.font(style: .body)
		textField.layer.cornerRadius = Theme.size(kind: .mediumRadius)

		textField.delegate = self

		return textField
	}
	func makeScheduleSelectButton() -> UIButton {
		let button = UIButton()
		button.setImage(Theme.image(kind: .chevronIcon), for: .normal)
		button.tintColor = Theme.color(usage: .gray)

		button.event = didSendEventClosure?(.selectSchedule(trackerSchedule))

		return button
	}
	func makeCategorySelectButton() -> UIButton {
		let button = UIButton()
		button.setImage(Theme.image(kind: .chevronIcon), for: .normal)
		button.tintColor = Theme.color(usage: .gray)

		button.event = didSendEventClosure?(.selectCategory(trackerCategory))

		return button
	}
	func makeCancelButton() -> UIButton {
		let button = UIButton()

		button.setTitle("Отменить", for: .normal)
		button.setTitleColor(Theme.color(usage: .attention), for: .normal)
		button.titleLabel?.font = Theme.font(style: .callout)
		button.backgroundColor = Theme.color(usage: .white)
		button.layer.cornerRadius = Theme.size(kind: .cornerRadius)
		button.layer.borderWidth = Theme.size(kind: .borderWight)
		button.layer.borderColor = Theme.color(usage: .attention).cgColor

		button.event = didSendEventClosure?(.cancel)

		return button
	}
	func makeCreateButton() -> UIButton {
		let button = UIButton()

		button.setTitle("Создать", for: .normal)
		button.setTitleColor(Theme.color(usage: .white), for: .normal)
		button.titleLabel?.font = Theme.font(style: .callout)
		button.backgroundColor = Theme.color(usage: .black)
		button.layer.cornerRadius = Theme.size(kind: .cornerRadius)

		button.event = didSendEventClosure?(.save)

		return button
	}
}

// MARK: - Appearance
private extension CreateEditTrackerViewController {
	enum Appearance {
		static let titleNew = "Новая привычка"
		static let titleEdit = "Редактирование привычки"
		static let textFieldPlaceholder = "Введите название трекера"
	}
}
