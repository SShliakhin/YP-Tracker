import UIKit

final class TrackersViewController: UIViewController {
	var didSendEventClosure: ((TrackersViewController.Event) -> Void)?
	private var searchText = "" { didSet { applySnapshot() } }

	private lazy var addTrackerBarButtonItem: UIBarButtonItem = makeAddTrackerBarButtonItem()
	private lazy var datePicker: UIDatePicker = makeDatePicker()
	private lazy var searchField: UISearchController = makeSearchField()

	private lazy var emptyView: UIView = makeEmptyView()

	// MARK: - Inits

	deinit {
		print("TrackersViewController deinit")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		applyStyle()
		setupConstraints()
	}
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
		navigationItem.searchController = searchField
	}
	func applyStyle() {
		title = Appearance.title
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setupConstraints() {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = Theme.spacing(usage: .standard)

		[
			emptyView
		].forEach { item in
			stackView.addArrangedSubview(item)
		}

		view.addSubview(stackView)
		stackView.makeEqualToSuperviewCenterToSafeArea()

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
	func makeSearchField() -> UISearchController {
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
