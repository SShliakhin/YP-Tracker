import UIKit

enum OnboardingPage: CaseIterable {
	case blue
	case red

	// как вариант развития
	var shouldShowSkipButton: Bool {
		switch self {
		case .blue, .red:
			return true
		}
	}

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

	// TODO: - пока думаю о необходимости ввода индексов
}

private extension OnboardingPage {
	enum Appearance {
		static let blueTextValue = "Отслеживайте только /nто, что хотите"
		static let redTextValue = "Даже если это /nне литры воды и йога"
	}
}
