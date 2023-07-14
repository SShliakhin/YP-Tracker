import UIKit

final class StatisticsViewController: UIViewController {
	private lazy var emptyView: UIView = makeEmptyView()

	// MARK: - Inits

	deinit {
		print("StatisticsViewController deinit")
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()

		setup()
		applyStyle()
		setConstraints()
	}
}

// MARK: - Event
extension StatisticsViewController {
	enum Event {
		case noEvent
	}
}

// MARK: - UI
private extension StatisticsViewController {
	func setup() {}
	func applyStyle() {
		view.backgroundColor = Theme.color(usage: .white)
	}
	func setConstraints() {
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
	}
}

// MARK: - UI make
private extension StatisticsViewController {
	func makeEmptyView() -> UIView {
		let view = EmptyView()
		view.update(with: EmptyInputData.emptyStatistics)
		return view
	}
}
