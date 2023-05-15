import Foundation

extension Theme {
	enum Constansts {
		static let aboutFilePath: String = {
			guard let bundle = Bundle.main.resourcePath else { return "" }
			return bundle + "/About.md"
		}()

		static let emojis = [
			"🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
			"🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
		]
	}
}
