/*
1. Выбор фильтра
 - дата сорс: TrackerFilter - постоянное
 - модель ячейки: checkmark
 - на входе текущее значение фильтра
 - на выходе выбранное значение фильтра

 - viewIsReady: подготовить дата сорс и показать текущий фильтр
 - при выборе: изменить состояние, отжать текущий, обозначить выбранный и выйти с выбранным
 */

import Foundation

protocol IYPInteractor {
	func viewIsReady()
	func didSelect(action: YPModels.Request)
}

final class YPInteractor: IYPInteractor {
	private let trackerAction: Tracker.Action
	private let presenter: IYPPresenter

	init(
		presenter: IYPPresenter,
		dep: IEmptyDependency,
		trackerAction: Tracker.Action
	) {
		self.presenter = presenter
		self.trackerAction = trackerAction
	}

	func viewIsReady() {
		switch trackerAction {
		case .edit(_):
			break
		case .new(_):
			break
		case .selectCategory(_):
			break
		case .selectSchedule(_):
			break
		case .save:
			break
		case .cancel:
			break
		case let .selectFilter(filter):
			presenter.present(data: YPModels.Response.selectFilter(filter, TrackerFilter.allValues))
		}
	}

	func didSelect(action: YPModels.Request) {
		switch action {
		case let .selectFilter(index, didSendEventClosure):
			let filter = TrackerFilter.allValues[index]
			presenter.present(data: YPModels.Response.selectFilter(filter, TrackerFilter.allValues))
			didSendEventClosure?(.didSelectFilter(filter))
		}
	}
}
