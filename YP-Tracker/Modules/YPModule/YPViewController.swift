import UIKit

protocol IYPViewController: AnyObject {
	/// Рендрит вьюмодель
	func render(viewModel: YPModels.ViewModel)
}

final class YPViewController: UIViewController {
	private let interactor: IYPInteractor
	private var dataSource: [YPModels.YPCellModel] = []
	var didSendEventClosure: ((YPViewController.Event) -> Void)?

	private lazy var tableView = makeTableView()

	// MARK: - Inits

	init(interactor: IYPInteractor) {
		self.interactor = interactor
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		print("IYPViewController deinit")
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

// MARK: - IYPViewController

extension YPViewController: IYPViewController {
	func render(viewModel: YPModels.ViewModel) {
		switch viewModel {
		case let .showFilters(viewData):
			dataSource = viewData
			tableView.reloadData()
		}
	}
}

// MARK: - Event
extension YPViewController {
	enum Event {
		case didSelectFilter(TrackerFilter)
	}
}

// MARK: - UITableViewDataSource

extension YPViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		dataSource.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let item = dataSource[indexPath.row]
		let model = YPCell.YPCellModel(
			type: item.type,
			title: item.title,
			description: item.description,
			hasDivider: item.hasDivider,
			outCorner: item.outCorner,
			isSelected: item.isSelected,
			event: item.event
		)
		return tableView.dequeueReusableCell(withModel: model, for: indexPath)
	}
}

// MARK: - UITableViewDataSource

extension YPViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		interactor.didSelect(action: .selectFilter(indexPath.row, didSendEventClosure))
	}
}

// MARK: - UI
private extension YPViewController {
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
		[
			tableView
		].forEach { view.addSubview($0) }
		tableView.makeEqualToSuperviewToSafeArea(
			insets: .init(
				top: 24,
				left: 16,
				bottom: 0,
				right: 16
			)
		)
	}
}

// MARK: - UI make
private extension YPViewController {
	func makeTableView() -> UITableView {
		let tableView = UITableView()

		tableView.register(models: [YPCell.YPCellModel.self])
		tableView.tableFooterView = UIView()

		tableView.dataSource = self
		tableView.delegate = self

		tableView.backgroundColor = .clear
		tableView.separatorStyle = .none
		tableView.bounces = false // чтобы не скролилось никуда

		tableView.rowHeight = Theme.size(kind: .textFieldHeight)

		return tableView
	}
}

// MARK: - Appearance
private extension YPViewController {
	enum Appearance {
		static let title = "Универсальный VC"
	}
}
