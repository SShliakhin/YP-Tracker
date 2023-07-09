import UIKit

final class TrackerCell: UICollectionViewCell {
	// MARK: - UI Elements

	fileprivate lazy var colorBackgroudnView = makeColorBackgroundView()
	fileprivate lazy var emojiLabel = makeEmojiLabel()
	fileprivate lazy var pinnedImageView = makePinnedImageView()
	fileprivate lazy var titleLabel = makeTitleLabel()
	fileprivate lazy var dayLabel = makeDayLabel()
	fileprivate lazy var completeButton = makeCompleteButton()

	// MARK: - Inits

	override init(frame: CGRect) {
		super.init(frame: frame)

		setConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Life cycle

	override func prepareForReuse() {
		super.prepareForReuse()
		colorBackgroudnView.backgroundColor = .clear
		emojiLabel.text = ""
		titleLabel.text = ""
		dayLabel.text = ""
		completeButton.event = nil
	}
}

// MARK: - Data model for cell

struct TrackerCellModel {
	let colorString: String
	let emoji: String
	let title: String
	let dayTime: String
	let isCompleted: Bool
	let isButtonEnabled: Bool
	let isPinned: Bool
	let event: (() -> Void)?
}

// MARK: - ICellViewModel

extension TrackerCellModel: ICellViewModel {
	func setup(cell: TrackerCell) {
		let color = UIColor(hex: colorString)

		cell.colorBackgroudnView.backgroundColor = color
		cell.emojiLabel.text = emoji
		cell.titleLabel.text = title
		cell.dayLabel.text = dayTime

		if isCompleted {
			cell.completeButton.setImage(Theme.image(kind: .checkmarkIcon), for: .normal) // UIImage(systemName: "checkmark")
			cell.completeButton.backgroundColor = color.withAlphaComponent(0.3)
		} else {
			cell.completeButton.setImage(Theme.image(kind: .addIcon), for: .normal) // UIImage(systemName: "plus")
			cell.completeButton.backgroundColor = color
		}
		cell.completeButton.event = event
		cell.completeButton.isEnabled = isButtonEnabled

		cell.pinnedImageView.isHidden = !isPinned
	}
}

// MARK: - UI
private extension TrackerCell {
	func setConstraints() {
		let localSpacing = Theme.spacing(usage: .constant12)

		let topStack = UIStackView()
		[
			emojiLabel,
			UIView(),
			pinnedImageView
		].forEach { topStack.addArrangedSubview($0) }
		[emojiLabel, pinnedImageView].forEach { $0.makeConstraints { $0.size(Theme.size(kind: .small)) } }

		let vStack = UIStackView()
		vStack.axis = .vertical
		vStack.spacing = Theme.spacing(usage: .standard)
		vStack.alignment = .leading
		[
			topStack,
			titleLabel
		].forEach { vStack.addArrangedSubview($0) }
		topStack.makeConstraints { [$0.trailingAnchor.constraint(equalTo: vStack.trailingAnchor)] }

		colorBackgroudnView.addSubview(vStack)
		vStack.makeEqualToSuperview(insets: .init(
			top: localSpacing,
			left: localSpacing,
			bottom: localSpacing,
			right: localSpacing
		))

		let bottomStack = UIStackView()
		bottomStack.spacing = Theme.spacing(usage: .standard)
		[
			dayLabel,
			completeButton
		].forEach { bottomStack.addArrangedSubview($0) }

		completeButton.makeConstraints { $0.size(Theme.size(kind: .medium)) }
		dayLabel.makeConstraints { [$0.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor)] }
		[
			colorBackgroudnView,
			bottomStack
		].forEach { contentView.addSubview($0) }

		colorBackgroudnView.makeConstraints { make in
			[
				make.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
				make.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
				make.heightAnchor.constraint(equalToConstant: Theme.dimension(kind: .largeHeight))
			]
		}
		bottomStack.makeConstraints { make in
			[
				make.topAnchor.constraint(equalTo: colorBackgroudnView.bottomAnchor, constant: Theme.spacing(usage: .standard)),
				make.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: localSpacing),
				make.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -localSpacing),
				make.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
			]
		}
	}
}

// MARK: - UI make
private extension TrackerCell {
	func makeColorBackgroundView() -> UIView {
		let view = UIView()
		view.layer.cornerRadius = Theme.dimension(kind: .cornerRadius)
		view.clipsToBounds = true

		return view
	}

	func makeEmojiLabel() -> UILabel {
		let label = UILabel()
		label.font = Theme.font(style: .caption1)
		label.textAlignment = .center
		label.backgroundColor = Theme.color(usage: .clear)
		label.layer.cornerRadius = Theme.dimension(kind: .largeRadius)
		label.clipsToBounds = true

		return label
	}

	func makePinnedImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.image = Theme.image(kind: .pinned)
		imageView.tintColor = Theme.color(usage: .allDayWhite)

		return imageView
	}

	func makeTitleLabel() -> UILabel {
		let label = UILabel()
		label.numberOfLines = 2
		label.font = Theme.font(style: .caption1)
		label.textColor = Theme.color(usage: .allDayWhite)

		return label
	}

	func makeDayLabel() -> UILabel {
		let label = UILabel()
		label.numberOfLines = 1
		label.font = Theme.font(style: .caption1)
		label.textColor = Theme.color(usage: .black)

		return label
	}

	func makeCompleteButton() -> UIButton {
		let button = UIButton()
		button.setImage(Theme.image(kind: .addIcon), for: .normal) // UIImage(systemName: "plus")
		button.layer.cornerRadius = 17
		button.clipsToBounds = true
		button.tintColor = Theme.color(usage: .white)

		return button
	}
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct TrackerCell_Previews: PreviewProvider {
	static var previews: some View {

		let view1 = TrackerCell()
		let model1 = TrackerCellModel(
			colorString: TrackerColor.blue.rawValue,
			emoji: "🏓",
			title: "Учить iOS много много учить еще учить",
			dayTime: "5 раз",
			isCompleted: false,
			isButtonEnabled: true,
			isPinned: true,
			event: nil
		)
		model1.setup(cell: view1)

		let view2 = TrackerCell()
		let model2 = TrackerCellModel(
			colorString: TrackerColor.orange.rawValue,
			emoji: "😇",
			title: "Бабушка прислала открытку в вотсапе",
			dayTime: "3 раза",
			isCompleted: true,
			isButtonEnabled: false,
			isPinned: false,
			event: nil
		)
		model2.setup(cell: view2)

		let view3 = TrackerCell()
		let model3 = TrackerCellModel(
			colorString: TrackerColor.green.rawValue,
			emoji: "😇",
			title: "Хорошее настроение",
			dayTime: "3 раза",
			isCompleted: false,
			isButtonEnabled: false,
			isPinned: false,
			event: nil
		)
		model3.setup(cell: view3)

		return VStack {
			HStack {
				view1.preview()
					.frame(width: 167, height: 120)

				view2.preview()
					.frame(width: 167, height: 120)
			}.padding(.vertical, 16)
			HStack {
				view3.preview()
				.frame(width: 167, height: 120)
			}
		}
	}
}
#endif
