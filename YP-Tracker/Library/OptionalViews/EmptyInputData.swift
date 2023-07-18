import UIKit

struct EmptyInputData {
	let image: UIImage
	let message: String
}

extension EmptyInputData {
	static let emptySearchTrackers = EmptyInputData(
		image: Theme.image(kind: .trackerEmptyPlaceholder),
		message: Theme.Texts.Messages.emptySearchListMessage
	)
	static let emptyStartTrackers = EmptyInputData(
		image: Theme.image(kind: .trackerStartPlaceholder),
		message: Theme.Texts.Messages.emptyTrackersListMessage
	)
	static let emptyStartCategories = EmptyInputData(
		image: Theme.image(kind: .trackerStartPlaceholder),
		message: Theme.Texts.Messages.emptyCategoriesListMessage
	)
	static let emptyStatistics = EmptyInputData(
		image: Theme.image(kind: .statsPlaceholder),
		message: Theme.Texts.Messages.emptyStatisticsListMessage
	)
}
