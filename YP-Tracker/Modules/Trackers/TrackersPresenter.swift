protocol ITrackersPresenter {
	/// Подготавливает данные на редринг вьюконтроллеру
	func present(data: TrackersModels.Response)
}

final class TrackersPresenter: ITrackersPresenter {
	weak var viewController: ITrackersViewController?

	func present(data: TrackersModels.Response) {

		let viewData: TrackersModels.ViewModel

		switch data {
		case let .update(categories):
			var sections: [TrackersModels.ViewModel.Section] = []
			for category in categories {
				let section = TrackersModels.ViewModel.Section(
					title: category.sectionName,
					trackers: category.trackers.map({ tracker, completed, allTimes in
						TrackersModels.ViewModel.TrackerModel(
							colorString: tracker.color,
							emoji: tracker.emoji,
							title: tracker.title,
							dayTime: "\(allTimes) дн./дней",
							isCompleted: completed
						)
					})
				)
				sections.append(section)
			}
			viewData = TrackersModels.ViewModel.update(sections)
		case let .updateTracker(section, row):
			let tracker = TrackersModels.ViewModel.TrackerModel(
				colorString: TrackerColor.green.rawValue,
				emoji: "",
				title: "",
				dayTime: "дн./дней",
				isCompleted: true
			)
			viewData = TrackersModels.ViewModel.updateTracker(
				section,
				row,
				tracker
			)
		}

		viewController?.render(viewModel: viewData)
	}
}
