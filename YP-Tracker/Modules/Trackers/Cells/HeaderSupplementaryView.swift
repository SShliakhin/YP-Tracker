import UIKit

final class HeaderSupplementaryView: UICollectionReusableView {
	// MARK: - UI Elements
	private lazy var headerLabel = makeHeaderLabel()

	// MARK: - Inits

	override init (frame: CGRect) {
		super.init(frame: frame)

		setConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Lifi cycle

	override func prepareForReuse() {
		super.prepareForReuse()

		headerLabel.text = nil
	}

	// MARK: - Data model for cell

	struct HeaderSupplementaryViewModel {
		let title: String
	}
}

// MARK: - ICellViewModel

extension HeaderSupplementaryView.HeaderSupplementaryViewModel: ICellViewModel {
	func setup(cell: HeaderSupplementaryView) {
		cell.headerLabel.text = title
	}
}

// MARK: - UI
private extension HeaderSupplementaryView {
	func setConstraints() {
		addSubview(headerLabel)
		headerLabel.makeEqualToSuperview()
	}
}

// MARK: - UI make
private extension HeaderSupplementaryView {
	func makeHeaderLabel() -> UILabel {
		let label = UILabel()
		label.font = Theme.font(style: .title2)
		label.textColor = Theme.color(usage: .black)

		return label
	}
}
