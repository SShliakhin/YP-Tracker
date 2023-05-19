import UIKit

protocol ITrackersViewController: AnyObject {
	/// Рендрит вьюмодель
	func render(viewModel: TrackersModels.ViewModel)
}

final class TrackersViewController: UIViewController {
	private let interactor: ITrackersInteractor
	private var dataSource: [TrackersModels.ViewModel.Section] = []
	var didSendEventClosure: ((TrackersViewController.Event) -> Void)?

	private var searchText = "" // { didSet { applySnapshot() } }

	private lazy var addTrackerBarButtonItem: UIBarButtonItem = makeAddTrackerBarButtonItem()
	private lazy var datePicker: UIDatePicker = makeDatePicker()
	private lazy var searchController: UISearchController = makeSearchController()

	private lazy var collectionView: UICollectionView = makeCollectionView()
	private lazy var emptyView: UIView = makeEmptyView()

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
}

// MARK: - ITrackersViewController

extension TrackersViewController: ITrackersViewController {
	func render(viewModel: TrackersModels.ViewModel) {
		switch viewModel {
		case let .update(sections):
			dataSource = sections
			collectionView.reloadData()
		case let .updateTracker(section, row, tracker):
			print("Обновить трекер:", section, row, tracker)
		}
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

		let tracker = dataSource[indexPath.section].trackers[indexPath.row]
		let model = TrackerCell.TrackerCellModel(
			colorString: tracker.colorString,
			emoji: tracker.emoji,
			title: tracker.title,
			dayTime: tracker.dayTime,
			isCompleted: tracker.isCompleted,
			event: { print("здесь событие на завершение трекера") }
		)
		return collectionView.dequeueReusableCell(withModel: model, for: indexPath)
	}

	func collectionView(
		_ collectionView: UICollectionView,
		viewForSupplementaryElementOfKind kind: String,
		at indexPath: IndexPath
	) -> UICollectionReusableView {

		let section = dataSource[indexPath.section]
		let model = HeaderSupplementaryView.HeaderSupplementaryViewModel(
			title: section.title
		)
		return collectionView.dequeueReusableSupplementaryView(
			kind: kind,
			withModel: model,
			for: indexPath
		)
	}
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
}

// MARK: - Event
extension TrackersViewController {
	enum Event {
		case addTracker
	}
}

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate, UISearchControllerDelegate {
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchText = ""
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		self.searchText = searchText.lowercased()
	}
}

// MARK: - Data filter
private extension TrackersViewController {
	func applySnapshot() {}
}

// MARK: - Actions
private extension TrackersViewController {
	@objc func didTapAddTrackerButton(_ sender: Any) {
		didSendEventClosure?(.addTracker)
	}
	@objc func didDateSelect(_ sender: Any) {
		print("Выбрана дата: \(datePicker.date)")
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
		title = Appearance.title
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {

		[
			collectionView,
			emptyView
		].forEach { item in
			view.addSubview(item)
		}

		collectionView.makeEqualToSuperviewToSafeArea()
		emptyView.makeEqualToSuperviewCenterToSafeArea()

		datePicker.makeConstraints { make in
			[
				make.widthAnchor.constraint(lessThanOrEqualToConstant: Appearance.datePickerWidth)
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
	func makeDatePicker() -> UIDatePicker {
		let picker = UIDatePicker()

		picker.datePickerMode = .date
		picker.preferredDatePickerStyle = .compact
		picker.locale = Locale(identifier: "ru-RU")

		picker.addTarget(self, action: #selector(didDateSelect), for: .valueChanged)

		return picker
	}
	func makeSearchController() -> UISearchController {
		let search = UISearchController()

		search.delegate = self
		search.searchBar.delegate = self

		search.searchBar.placeholder = Appearance.searchPlacholder
		search.searchBar.searchTextField.font = Theme.font(style: .body)
		search.searchBar.searchTextField.textColor = Theme.color(usage: .main)

		search.searchBar.setValue(Appearance.searchCancelButtonTitle, forKey: "cancelButtonText")

		return search
	}
	func makeEmptyView() -> UIView {
		let view = EmptyView()
		view.update(with: EmptyInputData.emptyStartTrackers)

		return view
	}

	func makeCollectionView() -> UICollectionView {
		let layout = createLayout()

		let collectionView = UICollectionView(
			frame: .zero,
			collectionViewLayout: layout
		)

		collectionView.register(models: [
			TrackerCell.TrackerCellModel.self
		])
		collectionView.registerSupplementaryView(models: [
			(HeaderSupplementaryView.HeaderSupplementaryViewModel.self, UICollectionView.elementKindSectionHeader)
		])

		collectionView.dataSource = self
		collectionView.delegate = self

		// пока здесь, надо в обновление потом
		emptyView.isHidden = true

		return collectionView
	}

	func createLayout() -> UICollectionViewCompositionalLayout {
		UICollectionViewCompositionalLayout { [weak self] _, _ in
			guard let self = self else { return nil }
			return self.createTrackerItemLayout()
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
		static let title = "Трекеры"
		static let datePickerWidth: CGFloat = 104
		static let searchPlacholder = "Поиск"
		static let searchCancelButtonTitle = "Отмена"
	}
}
