import Foundation

protocol ICreateEditCategoryPresenter {
	/// Подготавливает данные на редринг вьюконтроллеру
	func present(data: CreateEditCategoryModels.Response)
}

final class CreateEditCategoryPresenter: ICreateEditCategoryPresenter {
	weak var viewController: ICreateEditCategoryViewController?

	func present(data: CreateEditCategoryModels.Response) {

		switch data {
		case let .update(title, isSaveEnabled):
			viewController?.render(
				viewModel: .show(
					title: title,
					isSaveEnabled: isSaveEnabled
				)
			)
		case let .updateSaveEnabled(isSaveEnabled):
			viewController?.render(
				viewModel: .showSaveEnabled(
					isSaveEnabled: isSaveEnabled
				)
			)
		}
	}
}
