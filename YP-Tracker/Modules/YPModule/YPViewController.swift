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
	private lazy var actionButton: UIButton = makeActionButton()

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

		interactor.viewIsReady(actions: didSendEventClosure)
	}
}

// MARK: - IYPViewController

extension YPViewController: IYPViewController {
	func render(viewModel: YPModels.ViewModel) {
		switch viewModel {
		case
			let .showFilters(viewData),
			let .showSchedule(viewData),
			let .showCategories(viewData):

			actionButton.setTitle(viewData.titleButtonAction, for: .normal)
			actionButton.isHidden = viewData.titleButtonAction.isEmpty
			dataSource = viewData.dataSource
			tableView.reloadData()
		}
	}
}

// MARK: - Event
extension YPViewController {
	enum Event {
		case didSelectFilter(TrackerFilter)
		case didSelectSchedule([Int: Bool])
		case didSelectCategory(UUID)
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
		interactor.didSelectRow(indexPath.row)
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
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = Theme.spacing(usage: .standard3)
		stack.alignment = .center
		[
			tableView,
			actionButton
		].forEach { stack.addArrangedSubview($0) }

		tableView.makeConstraints { make in
			[
				make.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
				make.trailingAnchor.constraint(equalTo: stack.trailingAnchor)
			]
		}

		actionButton.makeConstraints { make in
			[
				make.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: Theme.spacing(usage: .standardHalf)),
				make.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: -Theme.spacing(usage: .standardHalf)),
				make.heightAnchor.constraint(equalToConstant: Theme.size(kind: .buttonHeight))
			]
		}

		view.addSubview(stack)
		stack.makeEqualToSuperviewToSafeArea(
			insets: .init(
				top: Theme.spacing(usage: .standard3),
				left: Theme.spacing(usage: .standard2),
				bottom: Theme.spacing(usage: .standard3),
				right: Theme.spacing(usage: .standard2)
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

		// скругление сверху и снизу - в ячейке значит не пригодилось (
		tableView.layer.cornerRadius = Theme.size(kind: .cornerRadius)
		tableView.clipsToBounds = true

		return tableView
	}
	func makeActionButton() -> UIButton {
		let button = UIButton()

		button.setTitle(Appearance.buttonTitle, for: .normal)
		button.setTitleColor(Theme.color(usage: .white), for: .normal)
		button.titleLabel?.font = Theme.font(style: .callout)
		button.backgroundColor = Theme.color(usage: .black)
		button.layer.cornerRadius = Theme.size(kind: .cornerRadius)

		// button.event = didSendEventClosure?(event)

		return button
	}
}

// MARK: - Appearance
private extension YPViewController {
	enum Appearance {
		static let title = "Универсальный VC"
		static let buttonTitle = "Действие"
	}
}
