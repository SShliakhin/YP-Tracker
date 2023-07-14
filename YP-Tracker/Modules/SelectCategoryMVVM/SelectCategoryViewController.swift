import UIKit

final class SelectCategoryViewController: UIViewController {
	private var viewModel: CategoriesListViewModel

	private lazy var collectionView: UICollectionView = makeCollectionView()
	private lazy var emptyView = makeEmptyView()
	private lazy var actionButton: UIButton = makeActionButton()

	// MARK: - Inits

	init(viewModel: CategoriesListViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("SelectCategoryViewController deinit")
	}

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		applyStyle()
		setConstraints()

		bind(to: viewModel)
		viewModel.viewIsReady()
	}
}

// MARK: - Bind

private extension SelectCategoryViewController {
	func bind(to viewModel: CategoriesListViewModel) {
		viewModel.items.observe(on: self) { [weak self] _ in
			self?.updateItems()
		}
	}

	func updateItems() {
		collectionView.reloadData()
		emptyView.isHidden = !viewModel.isEmpty
	}
}

// MARK: - UICollectionViewDataSource

extension SelectCategoryViewController: UICollectionViewDataSource {
	func collectionView(
		_ collectionView: UICollectionView,
		numberOfItemsInSection section: Int
	) -> Int {
		viewModel.numberOfItems
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let model = viewModel.cellModelAtIndex(indexPath.row)
		return collectionView.dequeueReusableCell(withModel: model, for: indexPath)
	}
}

// MARK: - UICollectionViewDelegate

extension SelectCategoryViewController: UICollectionViewDelegate {
	func collectionView(
		_ collectionView: UICollectionView,
		didSelectItemAt indexPath: IndexPath
	) {
		collectionView.deselectItem(at: indexPath, animated: true)
		viewModel.didUserDo(request: .selectItemAtIndex(indexPath.row))
	}

	func collectionView(
		_ collectionView: UICollectionView,
		contextMenuConfigurationForItemAt indexPaths: IndexPath,
		point: CGPoint
	) -> UIContextMenuConfiguration? {
		guard !indexPaths.isEmpty else { return nil }

		return UIContextMenuConfiguration(
			identifier: nil,
			previewProvider: nil,
			actionProvider: { _ in
				UIMenu(
					children:
						[
							UIAction(
								title: Appearance.menuEdit
							) { [weak self] _ in
								self?.viewModel.didUserDo(request: .editCategory(indexPaths.row))
							},
							UIAction(
								title: Appearance.menuDelete,
								attributes: .destructive
							) { [weak self] _ in
								self?.deleteRequest(indexPaths)
							}
						]
				)
			}
		)
	}

	private func deleteRequest(_ indexPath: IndexPath) {
		let alert = UIAlertController(
			title: nil,
			message: Appearance.deleteRequestMessage,
			preferredStyle: .actionSheet
		)
		alert.addAction(
			.init(
				title: Appearance.deleteRequestDeleteTitle,
				style: .destructive
			) { [weak self] _ in
				self?.viewModel.didUserDo(request: .deleteCategory(indexPath.row))
			}
		)
		alert.addAction(
			.init(
				title: Appearance.deleteRequestCancelTitle,
				style: .cancel
			)
		)
		present(alert, animated: true)
	}
}

// MARK: - UI
private extension SelectCategoryViewController {
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
		stack.spacing = Theme.spacing(usage: .standard)
		stack.alignment = .center
		[
			collectionView,
			actionButton
		].forEach { stack.addArrangedSubview($0) }

		collectionView.makeConstraints { make in
			[
				make.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
				make.trailingAnchor.constraint(equalTo: stack.trailingAnchor)
			]
		}

		actionButton.makeConstraints { make in
			[
				make.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: Theme.spacing(usage: .standardHalf)),
				make.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: -Theme.spacing(usage: .standardHalf)),
				make.heightAnchor.constraint(equalToConstant: Theme.dimension(kind: .smallHeight))
			]
		}

		[
			UIView(frame: .zero),
			stack,
			emptyView
		].forEach { view.addSubview($0) }

		stack.makeEqualToSuperviewToSafeArea(
			insets: .init(
				horizontal: Theme.spacing(usage: .standard2),
				vertical: Theme.spacing(usage: .standard3)
			)
		)
		emptyView.makeEqualToSuperviewCenterToSafeArea()
	}
}

// MARK: - UI make
private extension SelectCategoryViewController {
	func makeCollectionView() -> UICollectionView {
		let layout = createLayout()

		let collectionView = UICollectionView(
			frame: .zero,
			collectionViewLayout: layout
		)

		collectionView.register(models: [
			YPCellModel.self
		])

		collectionView.dataSource = self
		collectionView.delegate = self

		collectionView.backgroundColor = .clear
		collectionView.bounces = false

		collectionView.layer.cornerRadius = Theme.dimension(kind: .cornerRadius)
		collectionView.clipsToBounds = true

		return collectionView
	}
	func makeEmptyView() -> EmptyView {
		let view = EmptyView()
		view.update(with: EmptyInputData.emptyStartCategories)
		view.isHidden = true

		return view
	}
	func makeActionButton() -> UIButton {
		let button = UIButton()

		button.setTitle(Appearance.actionButtonTitle, for: .normal)
		button.setTitleColor(Theme.color(usage: .white), for: .normal)
		button.titleLabel?.font = Theme.font(style: .callout)
		button.backgroundColor = Theme.color(usage: .black)
		button.layer.cornerRadius = Theme.dimension(kind: .cornerRadius)

		button.event = { [weak self] in
			self?.viewModel.didUserDo(request: .tapActionButton)
		}

		return button
	}
}

// MARK: - CompositionalLayout
private extension SelectCategoryViewController {
	func createLayout() -> UICollectionViewCompositionalLayout {
		UICollectionViewCompositionalLayout { [weak self] _, _ in
			guard let self = self else { return nil }
			return self.createItemLayout()
		}
	}

	func createItemLayout() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .fractionalHeight(1.0)
		)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .absolute(Theme.dimension(kind: .largeHeight)) // высота
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
			supplementaryItem: [] // нет доп вьюх
		)

		return section
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
}

// MARK: - Appearance
private extension SelectCategoryViewController {
	enum Appearance {
		static let actionButtonTitle = "Добавить категорию"
		static let menuEdit = "Редактировать"
		static let menuDelete = "Удалить"
		static let deleteRequestMessage = "Эта категория точно не нужна?"
		static let deleteRequestDeleteTitle = "Удалить"
		static let deleteRequestCancelTitle = "Отменить"
	}
}
