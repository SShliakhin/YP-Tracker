import Foundation
enum YPModels {
	struct YPCellModel {
		let type: YPCell.InnerViewType
		let title: String
		let description: String
		let hasDivider: Bool
		let outCorner: [CellCorner]
		let isSelected: Bool
		let event: (() -> Void)?
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
