//
//  StatisticsCell.swift
import UIKit

final class StatisticsCell: UICollectionViewCell {
	// MARK: - UI Elements

	fileprivate lazy var titleLabel = makeTitleLabel()
	fileprivate lazy var descriptionLabel = makeDescriptionLabel()

	// MARK: - Inits

	override init(frame: CGRect) {
		super.init(frame: frame)

		applyStyle()
		setConstraints()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Life cycle

	override func prepareForReuse() {
		super.prepareForReuse()

		titleLabel.text = nil
		descriptionLabel.text = nil
	}
}

// MARK: - Data model for cell

struct StatisticsCellModel {
	let title: String
	let description: String
}

// MARK: - ICellViewModel

extension StatisticsCellModel: ICellViewModel {
	func setup(cell: StatisticsCell) {
		cell.titleLabel.text = title
		cell.descriptionLabel.text = description
	}
}

// MARK: - UI
private extension StatisticsCell {
	func applyStyle() {
		contentView.backgroundColor = Theme.color(usage: .white)
		contentView.layer.borderWidth = Theme.dimension(kind: .smallBorder)
		contentView.layer.cornerRadius = Theme.dimension(kind: .cornerRadius)
		let gradient = UIImage.gradientImage(
			bounds: contentView.bounds,
			colors: Theme.getGradientBorderColors(),
			direction: .right
		)
		contentView.layer.borderColor = UIColor(patternImage: gradient).cgColor
		contentView.clipsToBounds = true
	}
	func setConstraints() {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.spacing = Theme.spacing(usage: .standard)
		[
			titleLabel,
			descriptionLabel
		].forEach { stackView.addArrangedSubview($0) }

		contentView.addSubview(stackView)
		stackView.makeEqualToSuperview(
			insets: .init(all: Theme.spacing(usage: .constant12))
		)

		stackView.backgroundColor = Theme.color(usage: .white)
	}
}

// MARK: - UI make
private extension StatisticsCell {
	func makeTitleLabel() -> UILabel {
		let label = UILabel()
		label.font = Theme.font(style: .largeTitle)
		label.textColor = Theme.color(usage: .main)

		return label
	}
	func makeDescriptionLabel() -> UILabel {
		let label = UILabel()
		label.font = Theme.font(style: .caption1)
		label.textColor = Theme.color(usage: .main)

		return label
	}
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
struct StatisticsCell_Previews: PreviewProvider {
	static var previews: some View {

		let view1 = StatisticsCell()
		view1.overrideUserInterfaceStyle = .dark
		let model = StatisticsCellModel(title: "12", description: "Трекеров завершено")
		model.setup(cell: view1)

		let view2 = StatisticsCell()
		view2.overrideUserInterfaceStyle = .light
		model.setup(cell: view2)

		return VStack {
			view1.preview()
				.frame(width: 300, height: 90)
			view2.preview()
				.frame(width: 300, height: 90)
		}
	}
}
#endif
