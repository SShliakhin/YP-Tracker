import UIKit

enum OnboardingPage: CaseIterable {
	case blue
	case red

	var textValue: String {
		switch self {
		case .blue:
			return Appearance.blueTextValue
		case .red:
			return Appearance.redTextValue
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

private extension OnboardingPage {
	enum Appearance {
		static let blueTextValue = NSLocalizedString(
			"onboarding.bluePage.text",
			comment: "Текст на голубой странице онбординга"
		)
		static let redTextValue = NSLocalizedString(
			"onboarding.redPage.text",
			comment: "Текст на красной странице онбординга"
		)
	}
}
