//
//  ICreateEditTrackerInteractor.swift
import Foundation

protocol ICreateEditTrackerInteractor {
	func viewIsReady()
	func didUserDo(request: CreateEditTrackerModels.Request)
}

final class CreateEditTrackerInteractor: ICreateEditTrackerInteractor {
	private let trackerAction: Tracker.Action
	private let presenter: ICreateEditTrackerPresenter

	private var newTracker = Tracker(
		id: UUID(),
		title: "",
		emoji: "",
		color: "",
		schedule: Dictionary(uniqueKeysWithValues: (1...7).map { ($0, false) })
	)
	private var newCategory = ""

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
		case let .new(trackerType):
			presenter.present(
				data: .update(
					hasSchedule: trackerType == .habit,
					title: newTracker.title,
					components: [
						.category(newCategory),
						.schedule(newTracker.scheduleString),
						.emoji(Theme.Constansts.emojis, newTracker.emoji),
						.color(Theme.Constansts.trackerColors, newTracker.color)
					],
					isSaveEnabled: false
				)
			)
		case .selectCategory:
			break
		case .selectSchedule:
			break
		case .save:
			break
		case .cancel:
			break
		case .selectFilter:
			break
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
			newTracker = Tracker(
				id: newTracker.id,
				title: newTracker.title,
				emoji: Theme.Constansts.emojis[item],
				color: newTracker.color,
				schedule: newTracker.schedule
			)

			presenter.present(
				data: .updateSection(
					section: section,
					items: .emoji(
						Theme.Constansts.emojis,
						Theme.Constansts.emojis[item]
					),
					isSaveEnabled: false
				)
			)
		case let .newColor(section, item):
			newTracker = Tracker(
				id: newTracker.id,
				title: newTracker.title,
				emoji: newTracker.emoji,
				color: Theme.Constansts.trackerColors[item],
				schedule: newTracker.schedule
			)

			presenter.present(
				data: .updateSection(
					section: section,
					items: .color(
						Theme.Constansts.trackerColors,
						Theme.Constansts.trackerColors[item]
					),
					isSaveEnabled: false
				)
			)
		case .cancel:
			print("Отмена")
		case .save:
			print("Сохранение")
		}
	}
}
