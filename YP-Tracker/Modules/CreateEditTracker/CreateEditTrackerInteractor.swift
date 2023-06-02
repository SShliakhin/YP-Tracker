import Foundation

enum EventCreateEditTracker {
	case selectCategory(UUID?)
	case selectSchedule([Int: Bool])
	case save
	case cancel
}

protocol ICreateEditTrackerInteractor: AnyObject {
	func viewIsReady()
	func didUserDo(request: CreateEditTrackerModels.Request)

	var didSendEventClosure: ((EventCreateEditTracker) -> Void)? { get set }
}

final class CreateEditTrackerInteractor: ICreateEditTrackerInteractor {
	private let trackerAction: Tracker.Action
	private let presenter: ICreateEditTrackerPresenter

	var didSendEventClosure: ((EventCreateEditTracker) -> Void)?

	private var newTracker = Tracker(
		id: UUID(),
		title: "",
		emoji: "",
		color: "",
		schedule: Dictionary(uniqueKeysWithValues: (1...7).map { ($0, false) })
	)
	private var newCategory: (id: UUID?, title: String) = (nil, "")

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
						.category(newCategory.title),
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
			didSendEventClosure?(.selectCategory(newCategory.id))
		case .selectSchedule:
			didSendEventClosure?(.selectSchedule(newTracker.schedule))
		case let .newEmoji(section, item):
			presentSelectNewEmoji(section: section, item: item)
		case let .newColor(section, item):
			presentSelectNewColor(section: section, item: item)
		case .cancel:
			didSendEventClosure?(.cancel)
		case .save:
			didSendEventClosure?(.save)
		case let .newCategory(id, title):
			newCategory = (id, title)
			presenter.present(
				data: .updateSection(
					section: 0,
					items: .category(newCategory.title),
					isSaveEnabled: false
				)
			)
		case let .newSchedule(schedule):
			newTracker = Tracker(
				id: newTracker.id,
				title: newTracker.title,
				emoji: newTracker.emoji,
				color: newTracker.color,
				schedule: schedule
			)
			presenter.present(
				data: .updateSection(
					section: 1,
					items: .schedule(newTracker.scheduleString),
					isSaveEnabled: false
				)
			)
		}
	}
}

private extension CreateEditTrackerInteractor {
	func presentSelectNewEmoji(section: Int, item: Int) {
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
	}

	func presentSelectNewColor(section: Int, item: Int) {
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
	}
}
