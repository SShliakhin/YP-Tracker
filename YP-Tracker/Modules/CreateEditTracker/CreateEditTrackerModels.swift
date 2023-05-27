enum CreateEditTrackerModels {
	struct YPCellModel {
		let type: InnerViewType
		let title: String
		let description: String
		let hasDivider: Bool
		let outCorner: [CellCorner]
		let isSelected: Bool
		let event: (() -> Void)?
	}

	enum Request {
		case newTitle(String) // введено новое название - валидировать возможность сохранения
		case selectCategory // переход на экран выбора категории - необходимо запомните состояние трекера
		case selectSchedule // переход на экран выбора расписания - необходимо запомните состояние трекера
		case newEmoji(Int, Int) // выделена новое эмоджи - обновить секцию эмоджи + валидность сохранения
		case newColor(Int, Int) // выделен новый цвет - обновить секцию эмоджи + валидность сохранения
		case cancel // отмена - выход
		case save // сохранить состояние трекера - обновить существующий или добавить новый
	}

	enum Response {
		struct TrackerComponent {
			let title: String
			let isSelected: Bool
		}
		struct TrackerSections {
			let sectionName: String
			let items: [TrackerComponent]
		}
		case update(String, [TrackerSections])
	}

	enum ViewModel {
		case showFilters([YPCellModel])
	}
}
