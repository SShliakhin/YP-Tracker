import Foundation

extension Theme {
	// MARK: - DateFormatter
	static let dateFormatterCD: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yyyy"

		return formatter
	}()

	static let dateFormatterShortYear: DateFormatter = {
		let formatter = DateFormatter()

		let local = Locale.current.identifier
		if local.hasPrefix("ru") {
			formatter.dateFormat = "dd.MM.yy"
		} else {
			formatter.dateFormat = "MM/dd/yy"
		}

		return formatter
	}()

	static let dateFormatterStatistics: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"

		return formatter
	}()
}
