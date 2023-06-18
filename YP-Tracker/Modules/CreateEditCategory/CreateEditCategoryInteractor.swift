import Foundation

enum EventCreateEditCategory {
	case save
}

protocol ICreateEditCategoryInteractor: AnyObject {
	func viewIsReady()
	func didUserDo(request: CreateEditCategoryModels.Request)

	var didSendEventClosure: ((EventCreateEditCategory) -> Void)? { get set }
}

final class CreateEditCategoryInteractor: ICreateEditCategoryInteractor {
	private let categoriesManager: ICategoriesManager
	private let trackerAction: Tracker.Action
	private let presenter: ICreateEditCategoryPresenter

	var didSendEventClosure: ((EventCreateEditCategory) -> Void)?

	private var newCategory = TrackerCategory(
		id: UUID(),
		title: "",
		trackers: []
	)

	init(
		presenter: ICreateEditCategoryPresenter,
		dep: ICreateEditCategoryModuleDependency,
		trackerAction: Tracker.Action
	) {
		self.presenter = presenter
		self.categoriesManager = dep.categoriesManager
		self.trackerAction = trackerAction
	}

	func viewIsReady() {
		if case .addCategory = trackerAction {
			presenter.present(
				data: .update(
					title: newCategory.title,
					isSaveEnabled: false
				)
			)
		}
	}

	func didUserDo(request: CreateEditCategoryModels.Request) {
		switch request {
		case let .newTitle(title):
			newCategory = TrackerCategory(
				id: newCategory.id,
				title: title,
				trackers: []
			)
			presenter.present(
				data: .updateSaveEnabled(
					isSaveEnabled: !newCategory.title.isEmpty
				)
			)
		case .save:
			categoriesManager.addCategory(title: newCategory.title)
			didSendEventClosure?(.save)
		}
	}
}
