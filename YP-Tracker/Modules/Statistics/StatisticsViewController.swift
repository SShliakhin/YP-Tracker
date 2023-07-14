import UIKit

final class StatisticsViewController: UIViewController {
	private var viewModel: StatisticsListViewModel

	private lazy var collectionView: UICollectionView = makeCollectionView()
	private lazy var emptyView: UIView = EmptyView()
		.update(with: EmptyInputData.emptyStatistics)

	// MARK: - Inits
	init(viewModel: StatisticsListViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("StatisticsViewController deinit")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		applyStyle()
		setConstraints()

		bind()
		viewModel.viewIsReady()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		viewModel.didUserDo(request: .updateView)
	}
}

// MARK: - Bind

private extension StatisticsViewController {
	func bind() {
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

extension StatisticsViewController: UICollectionViewDataSource {
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

// MARK: - UI
private extension StatisticsViewController {
	func setup() {}
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		[
			UIView(frame: .zero),
			collectionView,
			emptyView
		].forEach { view.addSubview($0) }

		collectionView.makeEqualToSuperviewToSafeArea(
			insets: .init(
				horizontal: Theme.spacing(usage: .standard2),
				vertical: Theme.spacing(usage: .constant77)
			)
		)
		emptyView.makeEqualToSuperviewCenterToSafeArea()
	}
}

// MARK: - UI make
private extension StatisticsViewController {
	func makeCollectionView() -> UICollectionView {
		let layout = createLayout()

		let collectionView = UICollectionView(
			frame: .zero,
			collectionViewLayout: layout
		)

		collectionView.register(models: [
			StatisticsCellModel.self
		])

		collectionView.dataSource = self

		collectionView.backgroundColor = .clear
		collectionView.bounces = false

		return collectionView
	}
}

// MARK: - CompositionalLayout
private extension StatisticsViewController {
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
			interGroupSpacing: Theme.spacing(usage: .constant12), // по вертикали между группами
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
