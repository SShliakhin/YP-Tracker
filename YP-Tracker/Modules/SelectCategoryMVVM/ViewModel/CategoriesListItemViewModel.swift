struct CategoriesListItemViewModel {
	let type: InnerViewType = .checkmarkType
	let title: String
	let description = ""
	let hasDivider: Bool
	let outCorner: [CellCorner]
	let isSelected: Bool
	let event: (() -> Void)?
}

extension CategoriesListItemViewModel {
	init(
		category: TrackerCategory,
		first: Bool,
		last: Bool,
		isSelected: Bool,
		event: (() -> Void)?
	) {
		self.title = category.title
		self.hasDivider = !last

		switch (first, last) {
		case (true, true):
			self.outCorner = [.all]
		case (true, false):
			self.outCorner = [.top]
		case (false, true):
			self.outCorner = [.bottom]
		default:
			self.outCorner = []
		}

		self.isSelected = isSelected
		self.event = event
	}
}
