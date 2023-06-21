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
		static let emptySearchListMessage = "Ничего не найдено"
		static let emptyTrackersListMessage = "Что будем отслеживать?"
		static let emptyCategoriesListMessage = "Привычки и события можно\nобъединить по смыслу"
		static let emptyStatisticsListMessage = "Анализировать пока нечего"
	}
}
