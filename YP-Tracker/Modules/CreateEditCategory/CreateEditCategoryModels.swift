enum CreateEditCategoryModels {
	enum Request {
		case newTitle(String)
		case save
	}

	enum Response {
		case update(title: String, isSaveEnabled: Bool)
		case updateSaveEnabled(isSaveEnabled: Bool)
	}

	enum ViewModel {
		case show(title: String, isSaveEnabled: Bool)
		case showSaveEnabled(isSaveEnabled: Bool)
	}
}
