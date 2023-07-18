import UIKit

enum OnboardingPage: CaseIterable {
	case blue
	case red

	var textValue: String {
		switch self {
		case .blue:
			return Theme.Texts.OnboardingPages.blueTextValue
		case .red:
			return Theme.Texts.OnboardingPages.redTextValue
		}
	}

	var imageValue: UIImage {
		switch self {
		case .blue:
			return Theme.image(kind: .onboardingPage1)
		case .red:
			return Theme.image(kind: .onboardingPage2)
		}
	}
}
