import Foundation

extension Theme {
	// MARK: - DateFormatter
	static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		formatter.timeStyle = .none
		return formatter
	}()

	static let dateFormatterCD: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yyyy"
		formatter.locale = Locale(identifier: "ru-RU")
		return formatter
	}()
}
