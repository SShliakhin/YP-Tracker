import Foundation

protocol IYPPresenter {
	/// Подготавливает данные на редринг вьюконтроллеру
	func present(data: YPModels.Response)
}

final class YPPresenter: IYPPresenter {
	weak var viewController: IYPViewController?

	typealias ViewData = YPModels.ViewModel

	func present(data: YPModels.Response) {

		let viewData: ViewData

		switch data {
		case let .selectFilter(selectedFilter, allFilters):
			viewData = getDataForFilters(current: selectedFilter, array: allFilters)
		case let .selectSchedule(schedule, weekDays):
			viewData = getDataForSchedule(current: schedule, array: weekDays)
		case let .selectCategory(categoryID, categories):
			viewData = getDataForCategory(current: categoryID, array: categories)
		}

		viewController?.render(viewModel: viewData)
	}
}

private extension YPPresenter {
	func getDataForFilters(current: TrackerFilter, array: [TrackerFilter]) -> ViewData {
		let all = array.count
		var next = 1

		let dataSource: [YPCellModel] = array.map { item in
			let (hasDivider, outCorner) = getDecor(all: all, next: next)
			let isSelected = item == current

			next += 1
			return YPCellModel(
				type: .checkmarkType,
				title: item.description,
				description: "",
				hasDivider: hasDivider,
				outCorner: outCorner,
				isSelected: isSelected,
				event: nil
			)
		}
		return .showFilters(
			.init(
				dataSource: dataSource,
				titleButtonAction: ""
			)
		)
	}

	func getDataForSchedule(current: [Int: Bool], array: [String]) -> ViewData {
		let all = array.count
		var next = 1

		let dataSource: [YPCellModel] = array.map { item in
			let (hasDivider, outCorner) = getDecor(all: all, next: next)
			let isSelected = current[next] ?? false

			next += 1
			return YPCellModel(
				type: .switchType,
				title: item,
				description: "",
				hasDivider: hasDivider,
				outCorner: outCorner,
				isSelected: isSelected,
				event: nil
			)
		}

		return .showSchedule(
			.init(
				dataSource: dataSource,
				titleButtonAction: ActionsNames.readyButtonTitle
			)
		)
	}

	func getDataForCategory(current: UUID?, array: [TrackerCategory]) -> ViewData {
		let all = array.count
		var next = 1

		let dataSource: [YPCellModel] = array.map { item in
			let (hasDivider, outCorner) = getDecor(all: all, next: next)
			let isSelected = item.id == current

			next += 1
			return YPCellModel(
				type: .checkmarkType,
				title: item.title,
				description: "",
				hasDivider: hasDivider,
				outCorner: outCorner,
				isSelected: isSelected,
				event: nil
			)
		}

		return .showCategories(
			.init(
				dataSource: dataSource,
				titleButtonAction: CategoryNames.addCategoryButtonTitle
			)
		)
	}

	func getDecor(all: Int, next: Int) -> (hasDivider: Bool, outCorner: [CellCorner]) {
		guard all > 1 else { return (false, [.all]) }

		let hasDivider = all > next
		var outCorner: [CellCorner] = []
		if next == 1 {
			outCorner = [.top]
		} else if !hasDivider {
			outCorner = [.bottom]
		}
		return (hasDivider, outCorner)
	}
}
