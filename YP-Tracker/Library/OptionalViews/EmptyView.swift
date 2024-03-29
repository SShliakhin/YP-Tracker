import UIKit

final class EmptyView: UIView {
	// MARK: - UI Elements
	private lazy var emptyImageView = makeEmptyImageView()
	private lazy var emptyMessageLabel = makeEmptyMessageLabel()

	// MARK: - Inits
	override init(frame: CGRect) {
		super.init(frame: frame)

		applyStyle()
		setConstaints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension EmptyView {
	/// Метод для обновления данных во View
	@discardableResult
	func update(with data: EmptyInputData) -> Self {
		emptyImageView.image = data.image
		emptyMessageLabel.text = data.message
		return self
	}
}

// MARK: - UI
private extension EmptyView {
	func applyStyle() {
		backgroundColor = .clear
	}

	func setConstaints() {
		let backgroundView = UIView()
		addSubview(backgroundView)

		backgroundView.makeEqualToSuperview()

		let stackContainer = UIStackView()
		stackContainer.axis = .vertical
		stackContainer.distribution = .fill
		stackContainer.alignment = .center
		stackContainer.spacing = Theme.spacing(usage: .standard)

		[
			emptyImageView,
			emptyMessageLabel
		].forEach { stackContainer.addArrangedSubview($0) }

		backgroundView.addSubview(stackContainer)
		stackContainer.makeEqualToSuperview(
			insets: .init(all: Theme.spacing(usage: .standard))
		)
	}
}

// MARK: - UI make
private extension EmptyView {
	func makeEmptyImageView() -> UIImageView {
		let image = UIImageView()
		image.contentMode = .center
		return image
	}
	func makeEmptyMessageLabel() -> UILabel {
		let label = UILabel()
		label.textColor = Theme.color(usage: .main)
		label.font = Theme.font(style: .caption1)
		label.textAlignment = .center
		label.numberOfLines = .zero
		return label
	}
}
