import UIKit

struct EmptyInputData {
	let image: UIImage
	let message: String
}

extension EmptyInputData {
	static let emptySearchTrackers = EmptyInputData(
		image: Theme.image(kind: .trackerEmptyPlaceholder),
		message: Appearance.emptySearchListMessage
	)
	static let emptyStartTrackers = EmptyInputData(
		image: Theme.image(kind: .trackerStartPlaceholder),
		message: Appearance.emptyTrackersListMessage
	)
	static let emptyStartCategories = EmptyInputData(
		image: Theme.image(kind: .trackerStartPlaceholder),
		message: Appearance.emptyCategoriesListMessage
	)
	static let emptyStatistics = EmptyInputData(
		image: Theme.image(kind: .statsPlaceholder),
		message: Appearance.emptyStatisticsListMessage
	)
}

private extension EmptyInputData {
	enum Appearance {
		static let emptySearchListMessage = NSLocalizedString(
			"empty.searchList.message",
			comment: "Сообщение при неудачном поиске по текстовому шаблону"
		)
		static let emptyTrackersListMessage = NSLocalizedString(
			"empty.trackersList.message",
			comment: "Сообщение при отсутствие трекеров в базе"
		)
		static let emptyCategoriesListMessage = NSLocalizedString(
			"empty.categoriesList.message",
			comment: "Сообщение при отсутствие категорий в базе"
		)
		static let emptyStatisticsListMessage = NSLocalizedString(
			"empty.statisticsList.message",
			comment: "Сообщение при отсутствие статистики в базе"
		)
	}
}
