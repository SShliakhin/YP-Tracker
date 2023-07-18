import Foundation

enum CreateEditTrackerModels {
	struct SimpleCellModel {
		let title: String
		let isSelected: Bool
	}

	enum Request {
		case newTitle(String)
		case selectCategory
		case newCategory(UUID, String)
		case selectSchedule
		case newSchedule([Int: Bool])
		case newEmoji(Int, Int)
		case newColor(Int, Int)
		case cancel
		case save
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
					return Theme.Texts.TrackerSectionsNames.categoryTitle
				case .schedule:
					return Theme.Texts.TrackerSectionsNames.scheduleTitle
				case .emoji:
					return Theme.Texts.TrackerSectionsNames.emojiTitle
				case .color:
					return Theme.Texts.TrackerSectionsNames.colorTitle
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
					return Theme.Texts.TrackerSectionsNames.categoryTitle
				case .schedule:
					return Theme.Texts.TrackerSectionsNames.scheduleTitle
				case .emoji:
					return Theme.Texts.TrackerSectionsNames.emojiTitle
				case .color:
					return Theme.Texts.TrackerSectionsNames.colorTitle
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
