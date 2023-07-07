import UIKit

final class TrackerEmojiCell: UICollectionViewCell {
	// MARK: - UI Elements

	fileprivate lazy var background = makeBagroundView()
	fileprivate lazy var emojiLabel = makeEmojiLabel()

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
		emojiLabel.frame = bounds
	}

	override func prepareForReuse() {
		super.prepareForReuse()

		emojiLabel.text = nil
	}
}

// MARK: - Data model for cell

struct TrackerEmojiCellModel {
	let emoji: String
	let isSelected: Bool
}

// MARK: - ICellViewModel

extension TrackerEmojiCellModel: ICellViewModel {
	func setup(cell: TrackerEmojiCell) {
		cell.emojiLabel.text = emoji
		if isSelected {
			cell.background.fadeIn()
		} else {
			cell.background.fadeOut()
		}
	}
}

// MARK: - UI
private extension TrackerEmojiCell {
	func setConstraints() {
		[
			background,
			emojiLabel
		].forEach { contentView.addSubview($0) }
	}
}

// MARK: - UI make
private extension TrackerEmojiCell {
	func makeBagroundView() -> UIView {
		let view = UIView()
		view.layer.cornerRadius = Theme.dimension(kind: .cornerRadius)
		view.clipsToBounds = true
		view.backgroundColor = Theme.color(usage: .lightGray)

		return view
	}
	func makeEmojiLabel() -> UILabel {
		let label = UILabel()
		label.font = Theme.font(style: .title1)
		label.textAlignment = .center

		return label
	}
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct TrackerEmojiCell_Previews: PreviewProvider {
	static var previews: some View {

		let view1 = TrackerEmojiCell()
		let model1 = TrackerEmojiCellModel(emoji: "❤️", isSelected: false)
		model1.setup(cell: view1)

		let view2 = TrackerEmojiCell()
		let model2 = TrackerEmojiCellModel(emoji: "❤️", isSelected: true)
		model2.setup(cell: view2)

		let view3 = TrackerEmojiCell()
		model1.setup(cell: view3)

		return VStack {
			view1.preview()
				.frame(width: 52, height: 52)

			view2.preview()
				.frame(width: 200, height: 52)

			view3.preview()
				.frame(width: 200, height: 150)
		}
	}
}
#endif
