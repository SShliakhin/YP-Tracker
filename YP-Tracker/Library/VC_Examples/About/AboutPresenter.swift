protocol IAboutPresenter {
	/// Подготавливает данные на редринг вьюконтроллеру
	func present(text: String)
}

final class AboutPresenter: IAboutPresenter {
	weak var viewController: IAboutViewController?

	func present(text: String) {
		let viewData = AboutModels.ViewData(fileContents: text)
		viewController?.render(viewModel: viewData)
	}
}
