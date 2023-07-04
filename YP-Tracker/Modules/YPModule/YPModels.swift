import Foundation
enum YPModels {
	enum Request {
		case selectItemAtIndex(_ index: Int)
		case tapActionButton
		case updateView
	}

	enum Response {
		case selectFilter(TrackerFilter, [TrackerFilter])
		case selectSchedule([Int: Bool], [String])
		case selectCategory(UUID?, [TrackerCategory])
	}

	enum ViewModel {
		case showFilters(ViewData)
		case showSchedule(ViewData)
		case showCategories(ViewData)

		struct ViewData {
			let dataSource: [YPCellModel]
			let titleButtonAction: String
		}
	}
}
