import UIKit

final class TrackerColorCell: UICollectionViewCell {
	// MARK: - UI Elements

	private lazy var background = makeBagroundView()
	private lazy var colorView = makeColorView()

	// MARK: - Inits

	override init(frame: CGRect) {
		super.init(frame: frame)

		setConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Life cycle

	override func layoutSubviews() {
		super.layoutSubviews()

		background.frame = bounds
		colorView.frame = bounds.insetBy(dx: 6, dy: 6)
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		colorView.backgroundColor = .clear
	}

	// MARK: - Data model for cell

	struct TrackerColorCellModel {
		let colorString: String
		let isSelected: Bool
	}
}

// MARK: - ICellViewModel

extension TrackerColorCell.TrackerColorCellModel: ICellViewModel {
	func setup(cell: TrackerColorCell) {
		let color = UIColor(hex: colorString)
		cell.colorView.backgroundColor = color
		cell.background.layer.borderColor = color.withAlphaComponent(0.3).cgColor
		if isSelected {
			cell.background.fadeIn()
		} else {
			cell.background.fadeOut()
		}
	}
}

// MARK: - Public methods

extension TrackerColorCell {
	func update(isSelected: Bool = false) {
		if isSelected {
			background.fadeIn()
		} else {
			background.fadeOut()
		}
	}
}

// MARK: - UI
private extension TrackerColorCell {
	func setConstraints() {
		[
			background,
			colorView
		].forEach { contentView.addSubview($0) }
	}
}

// MARK: - UI make
private extension TrackerColorCell {
	func makeBagroundView() -> UIView {
		let view = UIView()

		view.layer.borderWidth = Theme.size(kind: .largeBorder)
		view.layer.cornerRadius = Theme.size(kind: .largeRadius)
		view.clipsToBounds = true

		return view
	}
	func makeColorView() -> UIView {
		let view = UIView()

		view.layer.cornerRadius = Theme.size(kind: .smallRadius)
		view.clipsToBounds = true

		return view
	}
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct TrackerColorCell_Previews: PreviewProvider {
	static var previews: some View {

		let view1 = TrackerColorCell()
		let model = TrackerColorCell.TrackerColorCellModel(colorString: TrackerColor.green.rawValue, isSelected: false)
		model.setup(cell: view1)

		let view2 = TrackerColorCell()
		model.setup(cell: view2)
		view2.update(isSelected: true)

		let view3 = TrackerColorCell()
		model.setup(cell: view3)

		return VStack {
			view1.preview()
				.frame(width: 52, height: 52)

			view2.preview()
				.frame(width: 52, height: 52)

			view3.preview()
				.frame(width: 100, height: 52)
		}
	}
}
#endif
