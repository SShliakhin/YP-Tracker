import UIKit

protocol ITrackersViewController: AnyObject {
	/// Рендрит вьюмодель
	func render(viewModel: TrackersModels.ViewModel)
}

final class TrackersViewController: UIViewController {
	private let interactor: ITrackersInteractor
	private var dataSource: [TrackersModels.ViewModel.Section] = []

	private var searchText = "" {
		didSet { if searchText != oldValue { didTypeSearchText(searchText) } }
	}

	// MARK: - UI Elements
	private lazy var addTrackerBarButtonItem: UIBarButtonItem = makeAddTrackerBarButtonItem()
	private lazy var datePicker = YPDatePickerLabelView()
		.updateAppearance(with: YPDatePickerLabelAppearance.defaultValue)
		.updateAction { [weak self] date in
			self?.didDateSelect(date: date)
		}
	private lazy var searchController: UISearchController = makeSearchController()

	private lazy var collectionView: UICollectionView = makeCollectionView()
	private lazy var emptyView = EmptyView()
		.update(with: EmptyInputData.emptyStartTrackers)
	private lazy var filtersButton = makeFiltersButton()

	// MARK: - Inits

	init(interactor: ITrackersInteractor) {
		self.interactor = interactor
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("TrackersViewController deinit")
	}

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		applyStyle()
		setConstraints()

		interactor.viewIsReady()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		interactor.didUserDo(request: .analyticsEvent(.screenOpen))
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		interactor.didUserDo(request: .analyticsEvent(.screenClose))
	}
}

// MARK: - Actions
private extension TrackersViewController {
	@objc func didTapAddTrackerButton(_ sender: Any) {
		interactor.didUserDo(request: .addTracker)
	}
	func didDateSelect(date: Date) {
		interactor.didUserDo(request: .newDate(date))
	}
	func didTypeSearchText(_ text: String) {
		searchController.searchBar.searchTextField.text = text
		interactor.didUserDo(request: .newSearchText(text))
	}

	func makeContextMenuByPlace(section: Int, row: Int) -> UIContextMenuConfiguration {
		let pinUnpinTitle = dataSource[section].trackers[row].isPinned
		? ActionsNames.menuTrackerUnpin
		: ActionsNames.menuTrackerPin

		let pinUnpinAction = UIAction(title: pinUnpinTitle) { [weak self] _ in
			self?.interactor.didUserDo(request: .pinUnpin(section, row))
		}

		let editAction = UIAction(title: ActionsNames.menuEdit) { [weak self] _ in
			self?.interactor.didUserDo(request: .editTracker(section, row))
		}

		let deleteAction = UIAction(
			title: ActionsNames.menuDelete,
			attributes: .destructive
		) { [weak self] _ in
			self?.deleteRequestByPlace(section: section, row: row)
		}

		return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			UIMenu(
				children:
					[
						pinUnpinAction,
						editAction,
						deleteAction
					]
			)
		}
	}

	func deleteRequestByPlace(section: Int, row: Int) {
		let alert = UIAlertController(
			title: nil,
			message: TrackerNames.deleteRequestMessage,
			preferredStyle: .actionSheet
		)
		alert.addAction(
			.init(
				title: ActionsNames.deleteButtonTitle,
				style: .destructive
			) { [weak self] _ in
				self?.interactor.didUserDo(request: .deleteTracker(section, row))
			}
		)
		alert.addAction(
			.init(
				title: ActionsNames.cancelButtonTitle,
				style: .cancel
			)
		)
		present(alert, animated: true)
	}
}

// MARK: - ITrackersViewController

extension TrackersViewController: ITrackersViewController {
	func render(viewModel: TrackersModels.ViewModel) {
		switch viewModel {
		case let .update(sections, conditions):
			dataSource = sections

			searchText = conditions.searchText
			datePicker.updateTitle(with: conditions.dateString)

			if conditions.hasAnyTrackers {
				emptyView.update(with: EmptyInputData.emptySearchTrackers)
			}
			emptyView.isHidden = !sections.isEmpty

			collectionView.reloadData()
		}
	}
}

// MARK: UIContextMenuInteractionDelegate

extension TrackersViewController: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(
		_ interaction: UIContextMenuInteraction,
		configurationForMenuAtLocation location: CGPoint
	) -> UIContextMenuConfiguration? {
		guard
			let location = interaction.view?.convert(location, to: collectionView),
			let indexPath = collectionView.indexPathForItem(at: location)
		else { return nil }

		return makeContextMenuByPlace(section: indexPath.section, row: indexPath.row)
	}
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		dataSource.count
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		dataSource[section].trackers.count
	}

	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {

		var model = dataSource[indexPath.section].trackers[indexPath.row]
		model.userInteraction = UIContextMenuInteraction(delegate: self) // интересно, так норм? перехват модели и вставка UI
		return collectionView.dequeueReusableCell(withModel: model, for: indexPath)
	}

	func collectionView(
		_ collectionView: UICollectionView,
		viewForSupplementaryElementOfKind kind: String,
		at indexPath: IndexPath
	) -> UICollectionReusableView {

		let model = dataSource[indexPath.section].header
		return collectionView.dequeueReusableSupplementaryView(
			kind: kind,
			withModel: model,
			for: indexPath
		)
	}
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		guard let newValue = searchController.searchBar.searchTextField.text?.lowercased() else { return }
		searchText = newValue
	}
}

// MARK: - UI
private extension TrackersViewController {
	func setup() {
		navigationItem.leftBarButtonItem = addTrackerBarButtonItem
		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
		navigationItem.searchController = searchController
	}
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
		[
			UIView(frame: .zero),
			collectionView,
			emptyView,
			filtersButton
		].forEach { view.addSubview($0) }

		collectionView.makeEqualToSuperviewToSafeArea()
		emptyView.makeEqualToSuperviewCenterToSafeArea()

		datePicker.makeConstraints { make in
			[
				make.widthAnchor.constraint(lessThanOrEqualToConstant: Appearance.datePickerWidth)
			]
		}

		filtersButton.makeConstraints { make in
			make.size(CGSize(width: 114, height: 50)) +
			[
				make.centerXAnchor.constraint(equalTo: view.centerXAnchor),
				make.bottomAnchor.constraint(
					equalTo: view.safeAreaLayoutGuide.bottomAnchor,
					constant: -Theme.spacing(usage: .standard2)
				)
			]
		}
	}
}

// MARK: - UI make
private extension TrackersViewController {
	func makeAddTrackerBarButtonItem() -> UIBarButtonItem {
		let button = UIBarButtonItem(
			image: Theme.image(kind: .addIcon),
			style: .plain,
			target: self,
			action: #selector(didTapAddTrackerButton)
		)
		button.tintColor = Theme.color(usage: .black)

		return button
	}
	func makeSearchController() -> UISearchController {
		let search = UISearchController(searchResultsController: nil)
		search.searchResultsUpdater = self
		search.obscuresBackgroundDuringPresentation = false

		let attributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: Theme.color(usage: .placeholder),
			.font: Theme.font(style: .body)
		]

		search.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
			string: TrackerNames.searchPlaceholder,
			attributes: attributes
		)

		search.searchBar.searchTextField.font = Theme.font(style: .body)
		search.searchBar.searchTextField.textColor = Theme.color(usage: .main)
		search.searchBar.searchTextField.backgroundColor = Theme.color(usage: .allDaySearchBase)

		return search
	}
	func makeFiltersButton() -> UIButton {
		let button = UIButton()

		button.setTitle(TrackerNames.filtersButtonTitle, for: .normal)
		button.setTitleColor(Theme.color(usage: .allDayWhite), for: .normal)
		button.titleLabel?.font = Theme.font(style: .body)
		button.backgroundColor = Theme.color(usage: .accent)
		button.layer.cornerRadius = Theme.dimension(kind: .cornerRadius)

		button.event = { [weak self] in
			self?.interactor.didUserDo(request: .selectFilter)
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
			TrackerCellModel.self
		])
		collectionView.registerSupplementaryView(models: [
			(HeaderSupplementaryViewModel.self, UICollectionView.elementKindSectionHeader)
		])

		collectionView.dataSource = self

		collectionView.backgroundColor = .clear

		return collectionView
	}
}

// MARK: - CompositionalLayout
private extension TrackersViewController {
	func createLayout() -> UICollectionViewCompositionalLayout {
		UICollectionViewCompositionalLayout { [weak self] _, _ in
			guard let self = self else { return nil }
			return self.createTrackerItemLayout()
		}
	}

	func createTrackerItemLayout() -> NSCollectionLayoutSection {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .fractionalHeight(1.0)
		)
		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let groupSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .absolute(132) // смог только так, какой то недочет в лайауте элемента
		)
		let group = NSCollectionLayoutGroup.horizontal(
			layoutSize: groupSize,
			subitem: item,
			count: 2 // кол-во элементов в группе
		)
		group.interItemSpacing = .fixed(9) // расстояние между элементами по горизонтали

		let section = createLayoutSection(
			group: group, // минимально let section = NSCollectionLayoutSection(group: group)
			behavior: .none, // важно для скроллинга
			interGroupSpacing: 16, // по вертикали между группами
			supplementaryItem: [supplementaryHeaderItem()]
		)

		section.contentInsets = .init(
			top: 12,
			leading: 16,
			bottom: 32,
			trailing: 16
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

	func supplementaryHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
		let itemSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .estimated(19.0)
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

// MARK: - Appearance
private extension TrackersViewController {
	enum Appearance {
		static let datePickerWidth: CGFloat = 77
	}
}
