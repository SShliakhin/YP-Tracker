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
		case selectFilter(Int, ((YPViewController.Event) -> Void)?)
	}

	enum Response {
		case selectFilter(TrackerFilter, [TrackerFilter])
	}

	enum ViewModel {
		case showFilters([YPCellModel])
	}
}
