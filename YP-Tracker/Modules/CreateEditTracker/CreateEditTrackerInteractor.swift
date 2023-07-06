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
	private let categoriesManager: ICategoriesManager
	private let trackerAction: Tracker.Action
	private let presenter: ICreateEditTrackerPresenter

	var didSendEventClosure: ((EventCreateEditTracker) -> Void)?

	private var newTracker = Tracker(
		id: UUID(),
		title: "",
		emoji: "",
		color: "",
		schedule: [:],
		pinned: false
	)
	private var newCategory: (id: UUID?, title: String) = (nil, "")
	private var isCorrectSchedule: Bool {
		var hasSchedule = false
		if case let .new(trackerType) = trackerAction {
			hasSchedule = trackerType == .habit
		}
		if case .edit = trackerAction {
			hasSchedule = !newTracker.schedule.isEmpty
		}
		return (hasSchedule && !newTracker.scheduleString.isEmpty) || !hasSchedule
	}

	init(
		presenter: ICreateEditTrackerPresenter,
		dep: ICreateEditTrackerModuleDependency,
		trackerAction: Tracker.Action
	) {
		self.presenter = presenter
		self.categoriesManager = dep.categoriesManager
		self.trackerAction = trackerAction
	}

	// swiftlint:disable:next function_body_length
	func viewIsReady() {
		var hasSchedule = false
		var isNewTracker = true

		if case let .new(trackerType) = trackerAction {
			hasSchedule = trackerType == .habit
			if hasSchedule {
				newTracker = Tracker(
					id: newTracker.id,
					title: newTracker.title,
					emoji: newTracker.emoji,
					color: newTracker.color,
					schedule: Dictionary(uniqueKeysWithValues: (1...7).map { ($0, false) }),
					pinned: false
				)
			}
		}

		if case let .edit(trackerID) = trackerAction {
			guard let trackerEditBox: (
				tracker: Tracker,
				categoryID: UUID,
				categoryTitle: String
			) = categoriesManager.getTrackerEditBoxByID(trackerID) else { return }
			let tracker = trackerEditBox.tracker
			hasSchedule = !tracker.scheduleString.isEmpty
			newTracker = Tracker(
				id: tracker.id,
				title: tracker.title,
				emoji: tracker.emoji,
				color: tracker.color,
				schedule: tracker.schedule,
				pinned: tracker.pinned
			)
			newCategory = (
				trackerEditBox.categoryID,
				trackerEditBox.categoryTitle
			)
			isNewTracker = false
		}

		presenter.present(
			data: .update(
				hasSchedule: hasSchedule,
				title: newTracker.title,
				components: [
					.category(newCategory.title),
					.schedule(newTracker.scheduleString),
					.emoji(Theme.Constansts.emojis, newTracker.emoji),
					.color(Theme.Constansts.trackerColors, newTracker.color)
				],
				isSaveEnabled: checkSavePossibility(),
				saveTitle: isNewTracker
				? Appearance.titleCreate
				: Appearance.titleEdit
			)
		)
	}

	func didUserDo(request: CreateEditTrackerModels.Request) {
		switch request {
		case let .newTitle(title):
			presentSelectNewTitle(title: title)
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
			guard let categoryID = newCategory.id else { return }
			categoriesManager.addTracker(
				tracker: newTracker,
				categoryID: categoryID
			)
			didSendEventClosure?(.save)
		case let .newCategory(id, title):
			newCategory = (id, title)
			presentSelectNewCategory()
		case let .newSchedule(schedule):
			presentSelectNewSchedule(schedule: schedule)
		}
	}
}

private extension CreateEditTrackerInteractor {
	func presentSelectNewTitle(title: String) {
		newTracker = Tracker(
			id: newTracker.id,
			title: title,
			emoji: newTracker.emoji,
			color: newTracker.color,
			schedule: newTracker.schedule,
			pinned: newTracker.pinned
		)
		presenter.present(
			data: .updateSaveEnabled(
				isSaveEnabled: checkSavePossibility()
			)
		)
	}
	func presentSelectNewCategory() {
		presenter.present(
			data: .updateSection(
				section: 0,
				items: .category(newCategory.title),
				isSaveEnabled: checkSavePossibility()
			)
		)
	}
	func presentSelectNewSchedule(schedule: [Int: Bool]) {
		newTracker = Tracker(
			id: newTracker.id,
			title: newTracker.title,
			emoji: newTracker.emoji,
			color: newTracker.color,
			schedule: schedule,
			pinned: newTracker.pinned
		)
		presenter.present(
			data: .updateSection(
				section: 1,
				items: .schedule(newTracker.scheduleString),
				isSaveEnabled: checkSavePossibility()
			)
		)
	}
	func presentSelectNewEmoji(section: Int, item: Int) {
		newTracker = Tracker(
			id: newTracker.id,
			title: newTracker.title,
			emoji: Theme.Constansts.emojis[item],
			color: newTracker.color,
			schedule: newTracker.schedule,
			pinned: newTracker.pinned
		)

		presenter.present(
			data: .updateSection(
				section: section,
				items: .emoji(
					Theme.Constansts.emojis,
					Theme.Constansts.emojis[item]
				),
				isSaveEnabled: checkSavePossibility()
			)
		)
	}
	func presentSelectNewColor(section: Int, item: Int) {
		newTracker = Tracker(
			id: newTracker.id,
			title: newTracker.title,
			emoji: newTracker.emoji,
			color: Theme.Constansts.trackerColors[item],
			schedule: newTracker.schedule,
			pinned: newTracker.pinned
		)

		presenter.present(
			data: .updateSection(
				section: section,
				items: .color(
					Theme.Constansts.trackerColors,
					Theme.Constansts.trackerColors[item]
				),
				isSaveEnabled: checkSavePossibility()
			)
		)
	}
	func checkSavePossibility() -> Bool {
		guard
			!newTracker.title.isEmpty,
			!newTracker.emoji.isEmpty,
			!newTracker.color.isEmpty,
			isCorrectSchedule,
			newCategory.id != nil
		else {
			return false
		}
		return true
	}
}

// MARK: - Appearance
private extension CreateEditTrackerInteractor {
	enum Appearance {
		static let titleCreate = "Создать"
		static let titleEdit = "Сохранить"
	}
}
