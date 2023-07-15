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
		struct UpdateBox {
			let hasSchedule: Bool
			let title: String
			let components: [Section]
			let isSaveEnabled: Bool
			let isNewTracker: Bool
			let totalCompletions: Int
		}
		case update(UpdateBox)
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
		struct UpdateBox {
			let hasSchedule: Bool
			let title: String
			let components: [Section]
			let isSaveEnabled: Bool
			let saveTitle: String
			let totalCompletionsString: String
		}
		case showAllComponents(UpdateBox)
		case showNewSection(section: Int, items: Section, isSaveEnabled: Bool)
		case showSaveEnabled(isSaveEnabled: Bool)
	}
}

private extension CreateEditTrackerModels {
	enum Appearance {
		static let categoryTitle = NSLocalizedString(
			"section.category.title",
			comment: "Заголовок секции Категория"
		)
		static let scheduleTitle = NSLocalizedString(
			"section.schedule.title",
			comment: "Заголовок секции Расписание"
		)
		static let emojiTitle = NSLocalizedString(
			"section.emoji.title",
			comment: "Заголовок секции Emoji"
		)
		static let colorTitle = NSLocalizedString(
			"section.color.title",
			comment: "Заголовок секции Цвет"
		)
	}
}
