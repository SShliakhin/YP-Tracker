import UIKit

extension Theme {
	// MARK: - Spacing
	enum Spacing {
		case standard
		case standard2
		case standardHalf
		case standard3
		case standard4
		case standard5
		case constant20
		case constant12
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
		case .standard5:
			customSpacing = 40
		case .constant20:
			customSpacing = 20
		case .constant12:
			customSpacing = 12
		}

		return customSpacing
	}

	// MARK: - Size
	enum Size {
		case cornerRadius
		case largeRadius
		case mediumRadius
		case smallRadius
		case textFieldHeight
		case buttonHeight
		case largeBorder
		case smallBorder
	}

	static func size(kind: Size) -> CGFloat {
		let customSize: CGFloat

		switch kind {
		case .cornerRadius:
			customSize = 16
		case .largeRadius:
			customSize = 12
		case .mediumRadius:
			customSize = 10
		case .smallRadius:
			customSize = 8
		case .textFieldHeight:
			customSize = 75
		case .buttonHeight:
			customSize = 60
		case .largeBorder:
			customSize = 3
		case .smallBorder:
			customSize = 1
		}

		return customSize
	}
}
