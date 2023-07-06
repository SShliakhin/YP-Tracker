import Foundation

protocol ITrackersPresenter {
	/// Подготавливает данные на редринг вьюконтроллеру
	func present(data: TrackersModels.Response)
}

final class TrackersPresenter: ITrackersPresenter {
	weak var viewController: ITrackersViewController?

	typealias TrackerSection = TrackersModels.ViewModel.Section

	func present(data: TrackersModels.Response) {

		let viewData: TrackersModels.ViewModel

		switch data {
		case let .update(categories, conditions, interactor):
			weak var interactor = interactor
			let isActionEnabled = checkIsActionEnabled(date: conditions.date)
			var sections: [TrackerSection] = []
			for (index, category) in categories.enumerated() {
				let section = TrackerSection(
					header: HeaderSupplementaryViewModel(title: category.sectionName),
					trackers: category.trackers
						.enumerated()
						.map({ key, val in
						TrackerCellModel(
							colorString: val.tracker.color,
							emoji: val.tracker.emoji,
							title: val.tracker.title,
							dayTime: "\(val.allTimes) дн./дней",
							isCompleted: val.completed,
							isButtonEnabled: isActionEnabled,
							isPinned: val.tracker.pinned,
							event: { interactor?.didUserDo(request: .completeUncompleteTracker(index, key)) }
						)
					})
				)
				sections.append(section)
			}
			viewData = .update(sections, conditions)
			viewController?.render(viewModel: viewData)
		}
	}
}

private extension TrackersPresenter {
	func checkIsActionEnabled(date: Date) -> Bool {
		Calendar.current.startOfDay(for: Date()) >= Calendar.current.startOfDay(for: date)
	}
}
