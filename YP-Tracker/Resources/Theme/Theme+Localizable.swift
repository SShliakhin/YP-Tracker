import Foundation

extension Theme {
	enum Localizable {
		static func daysCount(count: Int) -> String {
			let formatString = NSLocalizedString(
				"days",
				comment: "Количество дней - плюрализм"
			)
			return String.localizedStringWithFormat(formatString, count)
		}
	}
}
