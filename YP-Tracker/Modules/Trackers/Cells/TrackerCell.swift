import UIKit

final class TrackerCell: UICollectionViewCell {
	// MARK: - UI Elements

	private lazy var colorBackgroudnView = makeColorBackgroundView()
	private lazy var emojiLabel = makeEmojiLabel()
	private lazy var titleLabel = makeTitleLabel()
	private lazy var dayLabel = makeDayLabel()
	private lazy var completeButton = makeCompleteButton()

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

	// MARK: - Data model for cell

	struct TrackerCellModel {
		let colorString: String
		let emoji: String
		let title: String
		let dayTime: String
		let isCompleted: Bool
		let isButtonEnabled: Bool
		let event: (() -> Void)?
	}
}

// MARK: - ICellViewModel

extension TrackerCell.TrackerCellModel: ICellViewModel {
	func setup(cell: TrackerCell) {
		let color = UIColor(hex: colorString)

		cell.colorBackgroudnView.backgroundColor = color
		cell.emojiLabel.text = emoji
		cell.titleLabel.text = title
		cell.dayLabel.text = dayTime

		if isCompleted {
			cell.completeButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
			cell.completeButton.backgroundColor = color.withAlphaComponent(0.3)
		} else {
			cell.completeButton.setImage(UIImage(systemName: "plus"), for: .normal)
			cell.completeButton.backgroundColor = color
		}
		cell.completeButton.event = event
		cell.completeButton.isEnabled = isButtonEnabled
	}
}

// MARK: - UI
private extension TrackerCell {
	func setConstraints() {
		let vStack = UIStackView()
		vStack.axis = .vertical
		vStack.spacing = Theme.spacing(usage: .standard)
		vStack.alignment = .leading
		vStack.distribution = .fill
		[
			emojiLabel,
			titleLabel
		].forEach { vStack.addArrangedSubview($0) }

		emojiLabel.makeConstraints { $0.size(CGSize(width: 24, height: 24)) }

		colorBackgroudnView.addSubview(vStack)
		vStack.makeEqualToSuperview(insets: .init(
			top: 12,
			left: 12,
			bottom: 12,
			right: 12
		))

		let hStack = UIStackView()
		hStack.spacing = Theme.spacing(usage: .standard)
		[
			dayLabel,
			completeButton
		].forEach { hStack.addArrangedSubview($0) }

		hStack.makeConstraints { make in
			[
				make.heightAnchor.constraint(equalToConstant: 34)
			]
		}
		completeButton.makeConstraints { $0.size(CGSize(width: 34, height: 34)) }
		dayLabel.makeConstraints { make in
			[
				make.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor)
			]
		}

		[
			colorBackgroudnView,
			hStack
		].forEach { contentView.addSubview($0) }

		colorBackgroudnView.makeConstraints { make in
			[
				// make.topAnchor.constraint(equalTo: contentView.topAnchor),
				make.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
				make.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
				make.heightAnchor.constraint(equalToConstant: 90)
			]
		}
		hStack.makeConstraints { make in
			[
				make.topAnchor.constraint(equalTo: colorBackgroudnView.bottomAnchor, constant: Theme.spacing(usage: .standard)),
				make.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
				make.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
				make.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
			]
		}
	}
}

// MARK: - UI make
private extension TrackerCell {
	func makeColorBackgroundView() -> UIView {
		let view = UIView()
		view.layer.cornerRadius = Theme.size(kind: .cornerRadius)
		view.clipsToBounds = true

		return view
	}

	func makeEmojiLabel() -> UILabel {
		let label = UILabel()
		label.font = Theme.font(style: .caption1)
		label.textAlignment = .center
		label.backgroundColor = Theme.color(usage: .clear)
		label.layer.cornerRadius = Theme.size(kind: .largeRadius)
		label.clipsToBounds = true

		return label
	}

	func makeTitleLabel() -> UILabel {
		let label = UILabel()
		label.numberOfLines = 2
		label.font = Theme.font(style: .caption1)
		label.textColor = Theme.color(usage: .white)

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
		button.setImage(UIImage(systemName: "plus"), for: .normal)
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
		let model1 = TrackerCell.TrackerCellModel(
			colorString: TrackerColor.blue.rawValue,
			emoji: "🏓",
			title: "Учить iOS много много учить еще учить",
			dayTime: "5 раз",
			isCompleted: false,
			isButtonEnabled: true,
			event: nil
		)
		model1.setup(cell: view1)

		let view2 = TrackerCell()
		let model2 = TrackerCell.TrackerCellModel(
			colorString: TrackerColor.orange.rawValue,
			emoji: "😇",
			title: "Бабушка прислала открытку в вотсапе",
			dayTime: "3 раза",
			isCompleted: true,
			isButtonEnabled: false,
			event: nil
		)
		model2.setup(cell: view2)

		let view3 = TrackerCell()
		let model3 = TrackerCell.TrackerCellModel(
			colorString: TrackerColor.green.rawValue,
			emoji: "😇",
			title: "Хорошее настроение",
			dayTime: "3 раза",
			isCompleted: false,
			isButtonEnabled: false,
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
