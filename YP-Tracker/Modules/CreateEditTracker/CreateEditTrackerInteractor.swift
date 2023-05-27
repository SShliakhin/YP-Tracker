//
//  ICreateEditTrackerInteractor.swift
import Foundation

protocol ICreateEditTrackerInteractor {
	func viewIsReady()
	func didUserDo(request: CreateEditTrackerModels.Request)
	// func didSelect(action: YPModels.Request)
}

final class CreateEditTrackerInteractor: ICreateEditTrackerInteractor {
	private let trackerAction: Tracker.Action
	private let presenter: ICreateEditTrackerPresenter

	init(
		presenter: ICreateEditTrackerPresenter,
		dep: IEmptyDependency,
		trackerAction: Tracker.Action
	) {
		self.presenter = presenter
		self.trackerAction = trackerAction
	}

	func viewIsReady() {
		switch trackerAction {
		case .edit:
			break
		case .new:
			break
		case .selectCategory:
			break
		case .selectSchedule:
			break
		case .save:
			break
		case .cancel:
			break
		case let .selectFilter(filter):
			break
//			presenter.present(data: CreateEditTrackerModels.Response.selectFilter(filter, TrackerFilter.allValues))
		}
	}

	func didUserDo(request: CreateEditTrackerModels.Request) {
		switch request {
		case let .newTitle(title):
			print(title)
		case .selectCategory:
			print("Выбор категории")
		case .selectSchedule:
			print("Выбор расписания")
		case let .newEmoji(section, item):
			print("Выбор эмоджи в секции:", section, "и элемент под номером:", item)
		case let .newColor(section, item):
			print("Выбор цвета в секции:", section, "и элемент под номером:", item)
		case .cancel:
			print("Отмена")
		case .save:
			print("Сохранение")
		}
	}
}
