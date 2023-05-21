import UIKit

final class YPCell: UITableViewCell {
	// MARK: - UI Elements

	private lazy var titleLabel = makeTitleLabel()
	private lazy var descriptionLabel = makeDescriptionLabel()
	private lazy var dividerView = makeDividerView()

	private var innerView = UIView()
	private var event: (() -> Void)?

	// MARK: - Inits

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)

		applyStyle()
		setConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Life cycle

	override func prepareForReuse() {
		super.prepareForReuse()
		// до конца не понимаю, что надо обязательно здесь обнулять
		titleLabel.text = nil
		descriptionLabel.text = nil
		event = nil
		for view in innerView.subviews {
			view.removeFromSuperview()
		}
	}

	// MARK: - Data model for cell

	enum InnerViewType {
		case switchType
		case chevronType
		case checkmarkType
	}

	struct YPCellModel {
		let type: InnerViewType
		let title: String
		let description: String
		let hasDivider: Bool
		let outCorner: [CellCorner]
		let isSelected: Bool
		let event: (() -> Void)?
	}
}

// MARK: - ICellViewModel

extension YPCell.YPCellModel: ICellViewModel {
	func setup(cell: YPCell) {
		cell.titleLabel.text = title
		cell.descriptionLabel.text = description

		cell.dividerView.isHidden = !hasDivider
		cell.layer.maskedCorners = outCorner.cornerMask

		let innerView: UIView

		switch type {
		case .switchType:
			let switchView = cell.makeSwitch()
			switchView.isOn = isSelected
			innerView = switchView
		case .chevronType:
			innerView = cell.makeChevronImageView()
		case .checkmarkType:
			if isSelected {
				innerView = cell.makeCheckmarkImageView()
			} else {
				innerView = UIView()
			}
		}

		cell.innerView.addSubview(innerView)
		innerView.makeEqualToSuperview()

		cell.event = event
	}
}

// MARK: - UI
private extension YPCell {
	func applyStyle() {
		backgroundColor = Theme.color(usage: .background)
		layer.cornerRadius = Theme.size(kind: .mediumRadius)
		layer.masksToBounds = true

		// layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) // проверить
	}

	func setConstraints() {
		let vStack = UIStackView()
		vStack.axis = .vertical
		vStack.spacing = 2
		vStack.alignment = .leading
		[
			titleLabel,
			descriptionLabel
		].forEach { vStack.addArrangedSubview($0) }

		let hStack = UIStackView()
		hStack.spacing = Theme.spacing(usage: .standard)
		hStack.alignment = .center // чтобы надписи были по центру
		[
			vStack,
			innerView
		].forEach { hStack.addArrangedSubview($0) }

		hStack.makeConstraints { make in
			[
				make.heightAnchor.constraint(equalToConstant: Theme.size(kind: .textFieldHeight))
			]
		}

		[
			hStack,
			dividerView
		].forEach { contentView.addSubview($0) }

		hStack.makeEqualToSuperview(insets: .init(
			top: .zero,
			left: Theme.spacing(usage: .standard2),
			bottom: .zero,
			right: Theme.spacing(usage: .standard2)
		))

		dividerView.makeConstraints { make in
			[
				make.heightAnchor.constraint(equalToConstant: 1),
				make.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Theme.spacing(usage: .standard2)),
				make.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Theme.spacing(usage: .standard2)),
				make.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
			]
		}
	}
}

// MARK: - UI make
private extension YPCell {
	func makeTitleLabel() -> UILabel {
		let label = UILabel()
		label.font = Theme.font(style: .body)
		label.textColor = Theme.color(usage: .main)
		label.textAlignment = .center

		return label
	}
	func makeDescriptionLabel() -> UILabel {
		let label = UILabel()
		label.font = Theme.font(style: .body)
		label.textColor = Theme.color(usage: .gray)
		label.textAlignment = .center

		return label
	}
	func makeDividerView() -> UIView {
		let view = UIView()
		view.backgroundColor = Theme.color(usage: .gray)

		return view
	}
	func makeSwitch() -> UISwitch {
		let view = UISwitch()
		view.onTintColor = Theme.color(usage: .accent)

		return view
	}
	func makeCheckmarkImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.image = Theme.image(kind: .checkmarkIcon)
		imageView.tintColor = Theme.color(usage: .accent)

		return imageView
	}
	func makeChevronImageView() -> UIImageView {
		let imageView = UIImageView()
		imageView.image = Theme.image(kind: .chevronIcon)
		imageView.tintColor = Theme.color(usage: .gray)

		return imageView
	}
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct YPCell_Previews: PreviewProvider {
	static var previews: some View {

		let viewSwitch = YPCell()
		let modelSwitch = YPCell.YPCellModel(
			type: .switchType,
			title: "Label",
			description: "Описание",
			hasDivider: true,
			outCorner: [.top],
			isSelected: true,
			event: nil
		)
		modelSwitch.setup(cell: viewSwitch)

		let viewSwitch2 = YPCell()
		let modelSwitch2 = YPCell.YPCellModel(
			type: .switchType,
			title: "Label",
			description: "Описание",
			hasDivider: false,
			outCorner: [.bottom],
			isSelected: false,
			event: nil
		)
		modelSwitch2.setup(cell: viewSwitch2)

		let viewChevron = YPCell()
		let modelChevron = YPCell.YPCellModel(
			type: .chevronType,
			title: "Label",
			description: "Описание",
			hasDivider: true,
			outCorner: [.top],
			isSelected: true,
			event: nil
		)
		modelChevron.setup(cell: viewChevron)

		let viewChevron2 = YPCell()
		let modelChevron2 = YPCell.YPCellModel(
			type: .chevronType,
			title: "Label",
			description: "",
			hasDivider: false,
			outCorner: [.bottom],
			isSelected: false,
			event: nil
		)
		modelChevron2.setup(cell: viewChevron2)

		let viewCheckmark = YPCell()
		let modelCheckmark = YPCell.YPCellModel(
			type: .checkmarkType,
			title: "Label",
			description: "Описание",
			hasDivider: true,
			outCorner: [.top],
			isSelected: true,
			event: nil
		)
		modelCheckmark.setup(cell: viewCheckmark)

		let viewCheckmark2 = YPCell()
		let modelCheckmark2 = YPCell.YPCellModel(
			type: .checkmarkType,
			title: "Label",
			description: "Описание",
			hasDivider: false,
			outCorner: [.bottom],
			isSelected: false,
			event: nil
		)
		modelCheckmark2.setup(cell: viewCheckmark2)

		return VStack {
			VStack {
				viewSwitch.preview()
					.frame(height: 75)
					.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
				viewSwitch2.preview()
					.frame(height: 75)
					.padding(EdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16))

				viewChevron.preview()
					.frame(height: 75)
					.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
				viewChevron2.preview()
					.frame(height: 75)
					.padding(EdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16))

				viewCheckmark.preview()
					.frame(height: 75)
					.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
				viewCheckmark2.preview()
					.frame(height: 75)
					.padding(EdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16))
			}
		}
	}
}
#endif
