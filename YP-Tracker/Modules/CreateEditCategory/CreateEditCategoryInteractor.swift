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
		if case let .editCategory(categoryID) = trackerAction {
			guard let category = categoriesManager.getCategories()
					.first(where: { $0.id == categoryID }) else { return }
			newCategory = TrackerCategory(
				id: category.id,
				title: category.title,
				trackers: []
			)
		}
		presenter.present(
			data: .update(
				title: newCategory.title,
				isSaveEnabled: !newCategory.title.isEmpty
			)
		)
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
			if case .addCategory = trackerAction {
				categoriesManager.addCategory(
					title: newCategory.title
				)
			}
			if case .editCategory = trackerAction {
				categoriesManager.editCategoryBy(
					categoryID: newCategory.id,
					newtitle: newCategory.title
				)
			}
			didSendEventClosure?(.save)
		}
	}
}
