import UIKit

extension Theme {
	// MARK: - Spacing
	enum Spacing {
		case standard
		case standard2
		case standardHalf
		case standard3
		case standard4
	}

	static func spacing(usage: Spacing) -> CGFloat {
		let customSpacing: CGFloat

		switch usage {
		case .standard:
			customSpacing = 8
		case .standard2:
			customSpacing = 16
		case .standardHalf:
			customSpacing = 4
		case .standard3:
			customSpacing = 24
		case .standard4:
			customSpacing = 32
		}

		return customSpacing
	}

	// MARK: - Size
	enum Size {
		case cornerRadius
		case mediumRadius
		case smallRadius
		case textFieldHeight
		case buttonHeight
		case borderWight
	}

	static func size(kind: Size) -> CGFloat {
		let customSize: CGFloat

		switch kind {
		case .cornerRadius:
			customSize = 16
		case .mediumRadius:
			customSize = 10
		case .smallRadius:
			customSize = 8
		case .textFieldHeight:
			customSize = 75
		case .buttonHeight:
			customSize = 60
		case .borderWight:
			customSize = 1
		}

		return customSize
	}
}
