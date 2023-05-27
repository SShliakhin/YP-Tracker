import UIKit

protocol ICreateEditTrackerViewController: AnyObject {
	/// Рендрит вьюмодель
	func render(viewModel: CreateEditTrackerModels.ViewModel)
}

final class CreateEditTrackerViewController: UIViewController {
	private let interactor: ICreateEditTrackerInteractor
	private var dataSource: [CreateEditTrackerModels.YPCellModel] = []

	var didSendEventClosure: ((Tracker.Action) -> Void)?

	private lazy var titleTextField: UITextField = makeTitleTextField()
	private lazy var titleCharactersLimitLabel: UILabel = makeTitleCharactersLimitLabel()
	private lazy var collectionView = UICollectionView()

	private lazy var createButton: UIButton = makeButtonByEvent(.save)
	private lazy var cancelButton: UIButton = makeButtonByEvent(.cancel)

	// MARK: - Inits

	init(interactor: ICreateEditTrackerInteractor) {
		self.interactor = interactor
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
		setConstraints()
	}
}

// MARK: - ICreateEditTrackerViewController

extension CreateEditTrackerViewController: ICreateEditTrackerViewController {
	func render(viewModel: CreateEditTrackerModels.ViewModel) {
		switch viewModel {
		case let .showFilters(viewData):
			dataSource = viewData
		}
	}
}

// MARK: - UITextFieldDelegate

extension CreateEditTrackerViewController: UITextFieldDelegate {
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

	func setConstraints() {
		let vStackView = arrangeTextFieldBlockStackView()
		let hStackView = arrangeButtonsBlockStackView()

		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = Theme.spacing(usage: .standard4)
		[
			vStackView,
			//	collectionView,
			hStackView
		].forEach { stackView.addArrangedSubview($0) }

		let scrollView = UIScrollView()
		[
			stackView
		].forEach { scrollView.addSubview($0) }
		stackView.makeConstraints { make in
			[
				make.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
			]
		}

		view.addSubview(scrollView)
		scrollView.makeEqualToSuperviewToSafeArea(
			insets: .init(
				top: Theme.spacing(usage: .standard3),
				left: Theme.spacing(usage: .standard2),
				bottom: .zero,
				right: Theme.spacing(usage: .standard2)
			)
		)
	}

	func arrangeTextFieldBlockStackView() -> UIStackView {
		let textFieldView = UIView()
		textFieldView.backgroundColor = Appearance.backgroundColor
		textFieldView.layer.cornerRadius = Theme.size(kind: .cornerRadius)

		textFieldView.addSubview(titleTextField)
		titleTextField.makeEqualToSuperview(
			insets: .init(
				top: .zero,
				left: Theme.spacing(usage: .standard2),
				bottom: .zero,
				right: Theme.spacing(usage: .standard2)
			)
		)
		titleTextField.makeConstraints { make in
			[
				make.heightAnchor.constraint(equalToConstant: Theme.size(kind: .textFieldHeight))
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

	func arrangeButtonsBlockStackView() -> UIStackView {
		let hStackView = UIStackView()
		hStackView.spacing = Theme.spacing(usage: .standard)
		hStackView.distribution = .fillEqually
		[
			cancelButton,
			createButton
		].forEach { hStackView.addArrangedSubview($0) }
		hStackView.makeConstraints { make in
			[
				make.heightAnchor.constraint(equalToConstant: Theme.size(kind: .buttonHeight))
			]
		}

		return hStackView
	}
}

// MARK: - UI make
private extension CreateEditTrackerViewController {
	func makeTitleTextField() -> UITextField {
		let textField = UITextField()

		textField.placeholder = Appearance.textFieldPlaceholder
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
		label.text = Appearance.titleLimitMessage
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
			button.event = { self.interactor.didUserDo(request: .save) }
		case .cancel:
			button.event = { self.interactor.didUserDo(request: .cancel) }
		}

		return button
	}
}

private extension CreateEditTrackerViewController {
	enum ButtonEvent {
		case save
		case cancel

		func buttonTitleValue(_ button: UIButton) {
			button.titleLabel?.font = Theme.font(style: .callout)
			switch self {
			case .save:
				button.setTitle(Appearance.titleCreateButton, for: .normal)
				button.setTitleColor(Theme.color(usage: .white), for: .normal)
			case .cancel:
				button.setTitle(Appearance.titleCancelButton, for: .normal)
				button.setTitleColor(Theme.color(usage: .attention), for: .normal)
			}
		}

		func buttonLayerValue(_ button: UIButton) {
			button.layer.cornerRadius = Theme.size(kind: .cornerRadius)
			switch self {
			case .save:
				button.backgroundColor = Theme.color(usage: .black)
			case .cancel:
				button.backgroundColor = Theme.color(usage: .white)
				button.layer.borderWidth = Theme.size(kind: .smallBorder)
				button.layer.borderColor = Theme.color(usage: .attention).cgColor
			}
		}
	}
}

// MARK: - Appearance
private extension CreateEditTrackerViewController {
	enum Appearance {
		static let titleNew = "Новая привычка"
		static let titleEdit = "Редактирование привычки"
		static let textFieldPlaceholder = "Введите название трекера"
		static let textFieldLimit = 38
		static let titleLimitMessage = "Ограничение 38 символов"
		static let titleCreateButton = "Создать"
		static let titleCancelButton = "Отменить"
		static let backgroundColor = Theme.color(usage: .background).withAlphaComponent(0.30)
	}
}
