import UIKit

struct YPDatePickerLabelAppearance {
	let backgroundColor: UIColor
	let textColor: UIColor
	let textFont: UIFont
	let cornerRadius: CGFloat
}

extension YPDatePickerLabelAppearance {
	static let defaultValue = YPDatePickerLabelAppearance(
		backgroundColor: Theme.color(usage: .allDayBackground),
		textColor: Theme.color(usage: .allDayBlack),
		textFont: Theme.font(style: .body),
		cornerRadius: Theme.dimension(kind: .smallRadius)
	)
}

final class YPDatePickerLabelView: UIView {
	private var date = Date() { didSet { action?(date) } }
	private var action: ((Date) -> Void)?

	// MARK: - UI Elements
	private lazy var datePicker: UIDatePicker = makeDatePicker()
	private lazy var titleLabel: UILabel = makeTitleLabel()

	override init(frame: CGRect) {
		super.init(frame: frame)

		applyStyle()
		setConstaints()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension YPDatePickerLabelView {
	@discardableResult
	func updateAppearance(with appearance: YPDatePickerLabelAppearance) -> Self {
		titleLabel.textColor = appearance.textColor
		titleLabel.font = appearance.textFont
		titleLabel.backgroundColor = appearance.backgroundColor
		layer.cornerRadius = appearance.cornerRadius
		clipsToBounds = true

		return self
	}

	@discardableResult
	func updateTitle(with title: String) -> Self {
		self.titleLabel.text = title

		return self
	}

	@discardableResult
	func updateAction(action: @escaping (Date) -> Void) -> Self {
		self.action = action

		return self
	}
}

// MARK: - Actions
private extension YPDatePickerLabelView {
	@objc func didDateSelect(_ sender: Any) {
		date = datePicker.date
	}
}

// MARK: - UI
private extension YPDatePickerLabelView {
	func applyStyle() {
		backgroundColor = .clear
	}

	func setConstaints() {
		[datePicker, titleLabel].forEach {
			addSubview($0)
			$0.makeEqualToSuperview()
		}
	}
}

// MARK: - UI make
private extension YPDatePickerLabelView {
	func makeDatePicker() -> UIDatePicker {
		let picker = UIDatePicker()

		picker.datePickerMode = .date
		picker.preferredDatePickerStyle = .compact
		picker.locale = Locale(identifier: "ru-RU")

		picker.addTarget(self, action: #selector(didDateSelect), for: .valueChanged)

		return picker
	}
	func makeTitleLabel() -> UILabel {
		let label = UILabel()
		label.textAlignment = .center
		return label
	}
}
