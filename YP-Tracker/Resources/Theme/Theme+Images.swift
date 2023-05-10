import UIKit

extension Theme {
	// MARK: - Images
	enum ImageAsset: String {
		case practicumLogo
		case onboardingPage1
		case onboardingPage2

		case trackerStartPlaceholder
		case trackerEmptyPlaceholder
		case statsPlaceholder

		case tabTrackerIcon
		case tabStatsIcon

		case addIcon
		case checkmarkIcon
		case chevronIcon
	}

	static func image(kind: ImageAsset) -> UIImage {
		return UIImage(named: kind.rawValue) ?? .actions // swiftlint:disable:this image_name_initialization
	}
}
