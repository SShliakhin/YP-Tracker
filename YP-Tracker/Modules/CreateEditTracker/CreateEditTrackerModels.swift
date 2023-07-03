import Foundation

enum CreateEditTrackerModels {
	struct SimpleCellModel {
		let title: String
		let isSelected: Bool
	}

	enum Request {
		case newTitle(String) // введено новое название - валидировать возможность сохранения
		case selectCategory // переход на экран выбора категории - необходимо запомните состояние трекера
		case newCategory(UUID, String) // прийдет извне
		case selectSchedule // переход на экран выбора расписания - необходимо запомните состояние трекера
		case newSchedule([Int: Bool]) // прийдет извне
		case newEmoji(Int, Int) // выделена новое эмоджи - обновить секцию эмоджи + валидность сохранения
		case newColor(Int, Int) // выделен новый цвет - обновить секцию эмоджи + валидность сохранения
		case cancel // отмена - выход
		case save // сохранить состояние трекера - обновить существующий или добавить новый
	}

	enum Response {
		enum Section: CustomStringConvertible {
			case category(String)
			case schedule(String)
			case emoji([String], String)
			case color([String], String)

			var description: String {
				switch self {
				case .category:
					return Appearance.categoryTitle
				case .schedule:
					return Appearance.scheduleTitle
				case .emoji:
					return Appearance.emojiTitle
				case .color:
					return Appearance.colorTitle
				}
			}
		}
		case update(hasSchedule: Bool, title: String, components: [Section], isSaveEnabled: Bool)
		case updateSection(section: Int, items: Section, isSaveEnabled: Bool)
		case updateSaveEnabled(isSaveEnabled: Bool)
	}

	enum ViewModel {
		enum Section: CustomStringConvertible {
			case category(YPCellModel)
			case schedule(YPCellModel)
			case emoji([SimpleCellModel])
			case color([SimpleCellModel])

			var description: String {
				switch self {
				case .category:
					return Appearance.categoryTitle
				case .schedule:
					return Appearance.scheduleTitle
				case .emoji:
					return Appearance.emojiTitle
				case .color:
					return Appearance.colorTitle
				}
			}
		}
		case showAllComponents(hasSchedule: Bool, title: String, components: [Section], isSaveEnabled: Bool)
		case showNewSection(section: Int, items: Section, isSaveEnabled: Bool)
		case showSaveEnabled(isSaveEnabled: Bool)
	}
}

private extension CreateEditTrackerModels {
	enum Appearance {
		static let categoryTitle = "Категория"
		static let scheduleTitle = "Расписание"
		static let emojiTitle = "Emoji"
		static let colorTitle = "Цвет"
	}
}
