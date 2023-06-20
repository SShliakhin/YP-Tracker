enum CreateEditCategoryModels {
	enum Request {
		case newTitle(String) // введено новое название - валидировать возможность сохранения
		case save // сохранить состояние категории - обновить существующую или добавить новую
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
