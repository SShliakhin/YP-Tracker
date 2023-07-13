import Foundation

extension Theme {
	// MARK: - DateFormatter
	static let dateFormatterCD: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yyyy"
		formatter.timeStyle = .none
		formatter.locale = Locale(identifier: "ru-RU")
		return formatter
	}()

	static let dateFormatterShortYear: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yy"
		formatter.timeStyle = .none
		formatter.locale = Locale(identifier: "ru-RU")
		return formatter
	}()

	static let dateFormatterStatistics: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd"
		formatter.timeStyle = .none
		return formatter
	}()
}
