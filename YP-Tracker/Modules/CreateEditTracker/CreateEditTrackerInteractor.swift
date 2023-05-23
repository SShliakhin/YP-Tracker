//
//  ICreateEditTrackerInteractor.swift
import Foundation

protocol ICreateEditTrackerInteractor {
	func viewIsReady()
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
			presenter.present(data: CreateEditTrackerModels.Response.selectFilter(filter, TrackerFilter.allValues))
		}
	}
}
