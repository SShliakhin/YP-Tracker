struct CategoriesListItemViewModel {
	let title: String
	let isSelected: Bool
}

extension CategoriesListItemViewModel {
	init(
		category: TrackerCategory,
		isSelected: Bool
	) {
		self.title = category.title
		self.isSelected = isSelected
	}
}
