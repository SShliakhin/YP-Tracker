import UIKit

protocol ITrackersViewController: AnyObject {
	/// Рендрит вьюмодель
	func render(viewModel: TrackersModels.ViewModel)
}

final class TrackersViewController: UIViewController {
	let interactor: ITrackersInteractor
	private var dataSource: [TrackersModels.ViewModel.Section] = []

	private var searchText = "" {
		didSet {
			if searchText != oldValue {
				searchController.searchBar.searchTextField.text = searchText
				interactor.didUserDo(request: .newSearchText(searchText))
			}
		}
	}

	private lazy var addTrackerBarButtonItem: UIBarButtonItem = makeAddTrackerBarButtonItem()
	private lazy var datePicker: UIDatePicker = makeDatePicker()
	private lazy var searchController: UISearchController = makeSearchController()

	private lazy var collectionView: UICollectionView = makeCollectionView()
	private lazy var emptyView = makeEmptyView()
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
}

// MARK: - Event
extension TrackersViewController {
	enum Event {
		case addTracker(TrackerConditions)
		case selectFilter(TrackerConditions)
	}
}

// MARK: - Actions
private extension TrackersViewController {
	@objc func didTapAddTrackerButton(_ sender: Any) {
		interactor.didUserDo(request: .addTracker)
	}
	@objc func didDateSelect(_ sender: Any) {
		interactor.didUserDo(request: .newDate(datePicker.date))
	}
}

// MARK: - ITrackersViewController

extension TrackersViewController: ITrackersViewController {
	func render(viewModel: TrackersModels.ViewModel) {
		switch viewModel {
		case let .update(sections, conditions):
			dataSource = sections

			searchText = conditions.searchText
			datePicker.setDate(conditions.date, animated: true)

			if conditions.hasAnyTrackers {
				emptyView.update(with: EmptyInputData.emptySearchTrackers)
			}
			emptyView.isHidden = !sections.isEmpty

			collectionView.reloadData()
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
			isButtonEnabled: tracker.isActionEnabled,
			event: { [weak self] in
				self?.interactor.didUserDo(
					request: .completeUncompleteTracker(
						indexPath.section,
						indexPath.row
					)
				)
			}
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
			UIView(frame: .zero), // сделать навбар непрокручиваемым
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
	func makeDatePicker() -> UIDatePicker {
		let picker = UIDatePicker()

		picker.datePickerMode = .date
		picker.preferredDatePickerStyle = .compact
		picker.locale = Locale(identifier: "ru-RU")

		picker.addTarget(self, action: #selector(didDateSelect), for: .valueChanged)

		return picker
	}
	func makeSearchController() -> UISearchController {
		// VC сам покажет результат
		let search = UISearchController(searchResultsController: nil)
		// подписываемся
		search.searchResultsUpdater = self
		// рекомендации - вводим строку поиска и сразу видим результат
		search.obscuresBackgroundDuringPresentation = false

		search.searchBar.placeholder = Appearance.searchPlacholder
		search.searchBar.searchTextField.font = Theme.font(style: .body)
		search.searchBar.searchTextField.textColor = Theme.color(usage: .main)

		// хардкод для изменения надписи кнопки отмена, инетересно есть другой более правильный способ???
		search.searchBar.setValue(Appearance.searchCancelButtonTitle, forKey: "cancelButtonText")

		return search
	}
	func makeEmptyView() -> EmptyView {
		let view = EmptyView()
		view.update(with: EmptyInputData.emptyStartTrackers)

		return view
	}
	func makeFiltersButton() -> UIButton {
		let button = UIButton()

		button.setTitle(Appearance.filtersButtonTitle, for: .normal)
		button.setTitleColor(Theme.color(usage: .allDayWhite), for: .normal)
		button.titleLabel?.font = Theme.font(style: .body)
		button.backgroundColor = Theme.color(usage: .accent)
		button.layer.cornerRadius = Theme.size(kind: .cornerRadius)

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
			TrackerCell.TrackerCellModel.self
		])
		collectionView.registerSupplementaryView(models: [
			(HeaderSupplementaryView.HeaderSupplementaryViewModel.self, UICollectionView.elementKindSectionHeader)
		])

		collectionView.dataSource = self
		collectionView.delegate = self

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
		static let filtersButtonTitle = "Фильтры"
		static let datePickerWidth: CGFloat = 104
		static let searchPlacholder = "Поиск"
		static let searchCancelButtonTitle = "Отмена"
	}
}
