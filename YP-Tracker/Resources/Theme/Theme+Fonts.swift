import UIKit

enum Theme {
	// MARK: - Fonts
	enum FontStyle {
		case preferred(style: UIFont.TextStyle)
		case largeTitle // bold34
		case title1 // bold32
		case title2 // bold19
		case body // regular17
		case callout // medium16
		case caption1 // medium12
		case caption2 // medium10
	}

	static func font(style: FontStyle) -> UIFont {
		let customFont: UIFont

		switch style {
		case let .preferred(style: style):
			customFont = UIFont.preferredFont(forTextStyle: style)
		case .largeTitle:
			customFont = UIFont(name: "YSDisplay-Bold", size: 34.0) ?? UIFont.preferredFont(forTextStyle: .largeTitle)
		case .title1:
			customFont = UIFont(name: "YSDisplay-Bold", size: 32.0) ?? UIFont.preferredFont(forTextStyle: .title1)
		case .title2:
			customFont = UIFont(name: "YSDisplay-Bold", size: 19.0) ?? UIFont.preferredFont(forTextStyle: .title3)
		case .body:
			customFont = UIFont(name: "YandexSansDisplay-Regular", size: 17.0) ?? UIFont.preferredFont(forTextStyle: .body)
		case .callout:
			customFont = UIFont(name: "YSDisplay-Medium", size: 16.0) ?? UIFont.preferredFont(forTextStyle: .callout)
		case .caption1:
			customFont = UIFont(name: "YSDisplay-Medium", size: 12.0) ?? UIFont.preferredFont(forTextStyle: .caption1)
		case .caption2:
			customFont = UIFont(name: "YSDisplay-Medium", size: 10.0) ?? UIFont.preferredFont(forTextStyle: .caption2)
		}
		return customFont
	}
}
