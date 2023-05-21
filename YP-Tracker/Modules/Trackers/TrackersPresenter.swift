import Foundation

protocol ITrackersPresenter {
	/// Подготавливает данные на редринг вьюконтроллеру
	func present(data: TrackersModels.Response)
}

final class TrackersPresenter: ITrackersPresenter {
	weak var viewController: ITrackersViewController?

	typealias TrackerSection = TrackersModels.ViewModel.Section
	typealias TrackerModel = TrackersModels.ViewModel.TrackerModel

	func present(data: TrackersModels.Response) {

		let viewData: TrackersModels.ViewModel

		switch data {
		case let .update(categories, conditions):
			let isActionEnabled = checkIsActionEnabled(date: conditions.date)
			var sections: [TrackerSection] = []
			for category in categories {
				let section = TrackerSection(
					title: category.sectionName,
					trackers: category.trackers.map({ tracker, completed, allTimes in
						TrackerModel(
							colorString: tracker.color,
							emoji: tracker.emoji,
							title: tracker.title,
							dayTime: "\(allTimes) дн./дней",
							isCompleted: completed,
							isActionEnabled: isActionEnabled
						)
					})
				)
				sections.append(section)
			}
			viewData = TrackersModels.ViewModel.update(sections, conditions)
			viewController?.render(viewModel: viewData)
		}
	}

	private func checkIsActionEnabled(date: Date) -> Bool {
		Calendar.current.startOfDay(for: Date()) >= Calendar.current.startOfDay(for: date)
	}
}
