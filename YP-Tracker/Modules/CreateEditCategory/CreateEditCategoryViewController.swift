import UIKit

protocol ICreateEditCategoryViewController: AnyObject {
	/// Рендрит вьюмодель
	func render(viewModel: CreateEditCategoryModels.ViewModel)
}

final class CreateEditCategoryViewController: UIViewController {
	private let interactor: ICreateEditCategoryInteractor

	private var isSaveEnabled = false {
		didSet {
			actionButton.isEnabled = isSaveEnabled
			ButtonEvent.save.buttonTitleValue(actionButton)
			ButtonEvent.save.buttonLayerValue(actionButton)
		}
	}

	private lazy var titleTextField: UITextField = makeTitleTextField()
	private lazy var titleCharactersLimitLabel: UILabel = makeTitleCharactersLimitLabel()

	private lazy var actionButton: UIButton = makeButtonByEvent(.save)

	// MARK: - Inits

	init(interactor: ICreateEditCategoryInteractor) {
		self.interactor = interactor
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("CreateEditCategoryViewController deinit")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		applyStyle()
		setConstraints()

		interactor.viewIsReady()
	}
}

// MARK: - ICreateEditCategoryViewController

extension CreateEditCategoryViewController: ICreateEditCategoryViewController {
	func render(viewModel: CreateEditCategoryModels.ViewModel) {
		switch viewModel {
		case let .show(title, isSaveEnabled):
			self.isSaveEnabled = isSaveEnabled
			titleTextField.text = title
		case let .showSaveEnabled(isSaveEnabled):
			self.isSaveEnabled = isSaveEnabled
		}
	}
}

// MARK: - UITextFieldDelegate

extension CreateEditCategoryViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		isSaveEnabled = false
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		guard let text = textField.text else { return }
		let title = text.trimmingCharacters(in: .whitespacesAndNewlines)
		textField.text = title
		interactor.didUserDo(request: .newTitle(title))
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func textField(
		_ textField: UITextField,
		shouldChangeCharactersIn range: NSRange,
		replacementString string: String
	) -> Bool {
		let currentText = textField.text ?? ""
		let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
		return checkCharactersLimit(currentText: newText)
	}

	private func checkCharactersLimit(currentText: String) -> Bool {
		let isWithinLimit = currentText.count <= Appearance.textFieldLimit
		titleCharactersLimitLabel.isHidden = isWithinLimit
		return isWithinLimit
	}
}

// MARK: - UI
private extension CreateEditCategoryViewController {
	func setup() {
		navigationController?.navigationBar.prefersLargeTitles = false
		navigationController?.navigationBar.standardAppearance.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: Theme.color(usage: .black),
			NSAttributedString.Key.font: Theme.font(style: .callout)
		]

		hideKeyboardWhenTappedAround()
	}
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}

	func setConstraints() {
		let vStackView = arrangeTextFieldBlockStackView()
		[
			vStackView,
			actionButton
		].forEach { view.addSubview($0) }

		vStackView.makeConstraints { make in
			[
				make.topAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.topAnchor,
					constant: Theme.spacing(usage: .standard3)
				),
				make.leadingAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.leadingAnchor,
					constant: Theme.spacing(usage: .standard2)
				),
				make.trailingAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.trailingAnchor,
					constant: -Theme.spacing(usage: .standard2)
				)
			]
		}

		actionButton.makeConstraints { make in
			[
				make.heightAnchor.constraint(equalToConstant: Theme.dimension(kind: .smallHeight)),
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
					constant: -Theme.spacing(usage: .standard3)
				)
			]
		}
	}

	func arrangeTextFieldBlockStackView() -> UIStackView {
		let textFieldView = UIView()
		textFieldView.backgroundColor = Theme.color(usage: .background)
		textFieldView.layer.cornerRadius = Theme.dimension(kind: .cornerRadius)

		textFieldView.addSubview(titleTextField)
		titleTextField.makeEqualToSuperview(
			insets: .init(horizontal: Theme.spacing(usage: .standard2))
		)
		titleTextField.makeConstraints { make in
			[
				make.heightAnchor.constraint(equalToConstant: Theme.dimension(kind: .mediumHeight))
			]
		}

		let vStackView = UIStackView()
		vStackView.axis = .vertical
		vStackView.spacing = Theme.spacing(usage: .standard)
		[
			textFieldView,
			titleCharactersLimitLabel
		].forEach { vStackView.addArrangedSubview($0) }

		return vStackView
	}
}

// MARK: - UI make
private extension CreateEditCategoryViewController {
	func makeTitleTextField() -> UITextField {
		let textField = UITextField()

		let attributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: Theme.color(usage: .gray),
			.font: Theme.font(style: .body)
		]

		textField.attributedPlaceholder = NSAttributedString(
			string: CategoryNames.textFieldPlaceholder,
			attributes: attributes
		)

		textField.backgroundColor = .clear
		textField.textColor = Theme.color(usage: .main)
		textField.font = Theme.font(style: .body)

		textField.clearButtonMode = .whileEditing
		textField.returnKeyType = .done

		textField.delegate = self

		return textField
	}
	func makeTitleCharactersLimitLabel() -> UILabel {
		let label = UILabel()
		label.text = CategoryNames.titleLimitMessage
		label.textAlignment = .center
		label.textColor = Theme.color(usage: .attention)
		label.font = Theme.font(style: .body)
		label.isHidden = true

		return label
	}
	func makeButtonByEvent(_ event: ButtonEvent) -> UIButton {
		let button = UIButton()

		event.buttonTitleValue(button)
		event.buttonLayerValue(button)
		switch event {
		case .save:
			button.event = { [weak self] in
				self?.interactor.didUserDo(request: .save)
			}
		}

		return button
	}
}

// MARK: - ButtonEvent
private extension CreateEditCategoryViewController {
	enum ButtonEvent {
		case save

		func buttonTitleValue(_ button: UIButton) {
			button.titleLabel?.font = Theme.font(style: .callout)
			switch self {
			case .save:
				let titleColor = button.isEnabled
				? Theme.color(usage: .white)
				: Theme.color(usage: .allDayWhite)

				button.setTitle(ActionsNames.readyButtonTitle, for: .normal)
				button.setTitleColor(titleColor, for: .normal)
			}
		}

		func buttonLayerValue(_ button: UIButton) {
			button.layer.cornerRadius = Theme.dimension(kind: .cornerRadius)
			switch self {
			case .save:
				button.backgroundColor =
				button.isEnabled
				? Theme.color(usage: .black)
				: Theme.color(usage: .gray)
			}
		}
	}
}

// MARK: - Appearance
private extension CreateEditCategoryViewController {
	enum Appearance {
		static let textFieldLimit = 24
	}
}
