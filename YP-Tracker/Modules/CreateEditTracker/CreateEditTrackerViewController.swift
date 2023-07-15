import UIKit

protocol ICreateEditTrackerViewController: AnyObject {
	/// Рендрит вьюмодель
	func render(viewModel: CreateEditTrackerModels.ViewModel)
}

final class CreateEditTrackerViewController: UIViewController {
	private let interactor: ICreateEditTrackerInteractor
	private var dataSource: [CreateEditTrackerModels.ViewModel.Section] = []

	private var hasSchedule = false
	private var isSaveEnabled = false {
		didSet {
			createButton.isEnabled = isSaveEnabled
			ButtonEvent.save.buttonLayerValue(createButton)
		}
	}

	private lazy var titleTotalCompletionsLabel: UILabel = makeTitleTotalCompletionsLabel()
	private lazy var titleTextField: UITextField = makeTitleTextField()
	private lazy var titleCharactersLimitLabel: UILabel = makeTitleCharactersLimitLabel()
	private lazy var collectionView: UICollectionView = makeCollectionView()

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

		interactor.viewIsReady()
	}

	// инетересно! Есть лучший способ управлять высотой?
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		let colllectionViewHeight = hasSchedule
		? Appearance.colllectionViewHeightWithSchedule
		: Appearance.colllectionViewHeight
		collectionView.makeConstraints { make in
			[
				make.heightAnchor.constraint(equalToConstant: colllectionViewHeight)
			]
		}
	}
}

// MARK: - ICreateEditTrackerViewController

extension CreateEditTrackerViewController: ICreateEditTrackerViewController {
	func render(viewModel: CreateEditTrackerModels.ViewModel) {
		switch viewModel {
		case let .showAllComponents(updateBox):
			self.hasSchedule = updateBox.hasSchedule
			self.isSaveEnabled = updateBox.isSaveEnabled
			createButton.setTitle(updateBox.saveTitle, for: .normal)
			titleTextField.text = updateBox.title

			let totalCompletionsString = updateBox.totalCompletionsString
			titleTotalCompletionsLabel.text = totalCompletionsString
			titleTotalCompletionsLabel.isHidden = totalCompletionsString.isEmpty

			dataSource = updateBox.components
			collectionView.reloadData()
		case let .showNewSection(section, items, isSaveEnabled):
			self.isSaveEnabled = isSaveEnabled
			dataSource[section] = items
			collectionView.reloadSections([section])
		case let .showSaveEnabled(isSaveEnabled):
			self.isSaveEnabled = isSaveEnabled
		}
	}
}

// MARK: - UITextFieldDelegate

extension CreateEditTrackerViewController: UITextFieldDelegate {
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

// MARK: - UICollectionViewDataSource

extension CreateEditTrackerViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		dataSource.count
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let data = dataSource[section]
		switch data {
		case .category:
			return 1 // swiftlint:disable:this numbers_smell
		case .schedule:
			return hasSchedule ? 1 : .zero
		case let .emoji(items):
			return items.count
		case let .color(items):
			return items.count
		}
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let section = dataSource[indexPath.section]
		switch section {
		case let .category(category):
			return collectionView.dequeueReusableCell(withModel: category, for: indexPath)
		case let .schedule(schedule):
			return collectionView.dequeueReusableCell(withModel: schedule, for: indexPath)
		case let .emoji(emojis):
			let emoji = emojis[indexPath.row]
			let model = TrackerEmojiCellModel(
				emoji: emoji.title,
				isSelected: emoji.isSelected
			)
			return collectionView.dequeueReusableCell(withModel: model, for: indexPath)
		case let .color(colors):
			let color = colors[indexPath.row]
			let model = TrackerColorCellModel(
				colorString: color.title,
				isSelected: color.isSelected
			)
			return collectionView.dequeueReusableCell(withModel: model, for: indexPath)
		}
	}

	func collectionView(
		_ collectionView: UICollectionView,
		viewForSupplementaryElementOfKind kind: String,
		at indexPath: IndexPath
	) -> UICollectionReusableView {
		let section = dataSource[indexPath.section]
		let model = HeaderSupplementaryViewModel(
			title: section.description
		)
		return collectionView.dequeueReusableSupplementaryView(
			kind: kind,
			withModel: model,
			for: indexPath
		)
	}
}

// MARK: - UICollectionViewDelegate

extension CreateEditTrackerViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		let section = dataSource[indexPath.section]
		switch section {
		case .category:
			interactor.didUserDo(request: .selectCategory)
		case .schedule:
			interactor.didUserDo(request: .selectSchedule)
		case .emoji:
			interactor.didUserDo(request: .newEmoji(indexPath.section, indexPath.row))
		case .color:
			interactor.didUserDo(request: .newColor(indexPath.section, indexPath.row))
		}
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

		hideKeyboardWhenTappedAround()
	}
	func applyStyle() {
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
			collectionView,
			hStackView
		].forEach { stackView.addArrangedSubview($0) }

		let scrollView = UIScrollView()
		[
			stackView
		].forEach { scrollView.addSubview($0) }
		stackView.makeEqualToSuperview(insets: .init(
			top: Theme.spacing(usage: .standard3),
			left: Theme.spacing(usage: .standard2),
			bottom: .zero,
			right: Theme.spacing(usage: .standard2)
		))
		stackView.makeConstraints { make in
			[
				make.widthAnchor.constraint(
					equalTo: scrollView.widthAnchor,
					constant: -Theme.spacing(usage: .standard4)
				)
			]
		}

		[
			UIView(frame: .zero),
			scrollView
		].forEach { view.addSubview($0) }
		scrollView.makeEqualToSuperviewToSafeArea()
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
			titleTotalCompletionsLabel,
			textFieldView,
			titleCharactersLimitLabel
		].forEach { vStackView.addArrangedSubview($0) }

		vStackView.setCustomSpacing(
			Theme.spacing(usage: .standard5),
			after: titleTotalCompletionsLabel
		)

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
				make.heightAnchor.constraint(equalToConstant: Theme.dimension(kind: .smallHeight))
			]
		}

		return hStackView
	}
}

// MARK: - UI make
private extension CreateEditTrackerViewController {
	func makeTitleTotalCompletionsLabel() -> UILabel {
		let label = UILabel()
		label.textAlignment = .center
		label.textColor = Theme.color(usage: .main)
		label.font = Theme.font(style: .title1)
		label.isHidden = true

		return label
	}
	func makeTitleTextField() -> UITextField {
		let textField = UITextField()

		textField.placeholder = TrackerNames.textFieldPlaceholder
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
		label.text = TrackerNames.titleLimitMessage
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
		case .cancel:
			button.event = { [weak self] in
				self?.interactor.didUserDo(request: .cancel)
			}
		}

		return button
	}

	func makeCollectionView() -> UICollectionView {
		let layout = createLayout()

		let collectionView = UICollectionView(
			frame: .zero,
			collectionViewLayout: layout
		)

		collectionView.register(models: [
			YPCellModel.self,
			TrackerEmojiCellModel.self,
			TrackerColorCellModel.self
		])
		collectionView.registerSupplementaryView(models: [
			(HeaderSupplementaryViewModel.self, UICollectionView.elementKindSectionHeader)
		])

		collectionView.dataSource = self
		collectionView.delegate = self

		collectionView.backgroundColor = .clear
		collectionView.bounces = false // чтобы не скролилось никуда

		return collectionView
	}
}

// MARK: - CompositionalLayout
private extension CreateEditTrackerViewController {
	func createLayout() -> UICollectionViewCompositionalLayout {
		UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
			guard let self = self else { return nil }
			let section = self.dataSource[sectionIndex]
			switch section {
			case .category:
				return self.createYPCellLayout()
			case .schedule:
				return self.createYPCellLayout()
			case .emoji:
				return self.createSimpleCellLayout()
			case .color:
				return self.createSimpleCellLayout()
			}
		}
	}

	func createLayoutSection(
		group: NSCollectionLayoutGroup,
		behavior: UICollectionLayoutSectionOrthogonalScrollingBehavior,
		interGroupSpacing: CGFloat,
		supplementaryItem: [NSCollectionLayoutBoundarySupplementaryItem]
	) -> NSCollectionLayoutSection {
		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = behavior
		section.interGroupSpacing = interGroupSpacing
		section.boundarySupplementaryItems = supplementaryItem

		return section
	}

	func createYPCellLayout() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .fractionalHeight(1.0)
		)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .absolute(Theme.dimension(kind: .mediumHeight))
		)
		let group = NSCollectionLayoutGroup.horizontal(
			layoutSize: groupSize,
			subitem: item,
			count: 1 // кол-во элементов в группе
		)

		let section = createLayoutSection(
			group: group, // минимально let section = NSCollectionLayoutSection(group: group)
			behavior: .none, // важно для скроллинга
			interGroupSpacing: .zero, // по вертикали между группами
			supplementaryItem: []
		)

		return section
	}

	func createSimpleCellLayout() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .fractionalHeight(1.0)
		)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .absolute(Appearance.itemHeight)
		)
		let group = NSCollectionLayoutGroup.horizontal(
			layoutSize: groupSize,
			subitem: item,
			count: Appearance.itemCount // кол-во элементов в группе
		)
		group.interItemSpacing = .fixed(Theme.spacing(usage: .standard)) // расстояние между элементами по горизонтали

		let section = createLayoutSection(
			group: group, // минимально let section = NSCollectionLayoutSection(group: group)
			behavior: .none, // важно для скроллинга
			interGroupSpacing: .zero, // по вертикали между группами
			supplementaryItem: [supplementaryHeaderItem()]
		)

		return section
	}

	func supplementaryHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .absolute(Theme.dimension(kind: .mediumHeight))
		)
		let item = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: itemSize,
			elementKind: UICollectionView.elementKindSectionHeader,
			alignment: .topLeading
		)

		item.contentInsets = .init(
			top: .zero,
			leading: 12,
			bottom: .zero,
			trailing: 12
		)

		return item
	}
}

// MARK: - ButtonEvent
private extension CreateEditTrackerViewController {
	enum ButtonEvent {
		case save
		case cancel

		func buttonTitleValue(_ button: UIButton) {
			button.titleLabel?.font = Theme.font(style: .callout)
			switch self {
			case .save:
				button.setTitle(ActionsNames.createButtonTitle, for: .normal)
				button.setTitleColor(Theme.color(usage: .white), for: .normal)
			case .cancel:
				button.setTitle(ActionsNames.cancelButtonTitle, for: .normal)
				button.setTitleColor(Theme.color(usage: .attention), for: .normal)
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
			case .cancel:
				button.backgroundColor = Theme.color(usage: .white)
				button.layer.borderWidth = Theme.dimension(kind: .smallBorder)
				button.layer.borderColor = Theme.color(usage: .attention).cgColor
			}
		}
	}
}

// MARK: - Appearance
private extension CreateEditTrackerViewController {
	enum Appearance {
		static let textFieldLimit = 38
		static let colllectionViewHeightWithSchedule: CGFloat = 618.0
		static let colllectionViewHeight: CGFloat = 543.0
		static let itemHeight = 52.0
		static let itemCount = 6
	}
}
