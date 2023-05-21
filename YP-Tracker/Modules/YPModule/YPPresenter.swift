//
//  YPPresenter.swift
import Foundation

protocol IYPPresenter {
	/// Подготавливает данные на редринг вьюконтроллеру
	func present(data: YPModels.Response)
}

final class YPPresenter: IYPPresenter {
	weak var viewController: IYPViewController?

	func present(data: YPModels.Response) {

		let viewData: YPModels.ViewModel

		switch data {
		case let .selectFilter(selectedFilter, allFilters):
			let all = allFilters.count
			var next = 1

			let viewModel: [YPModels.YPCellModel] = allFilters.map { filter in

				let hasDivider = all > next

				var outCorner: [CellCorner] = []
				if next == 1 {
					outCorner = [.top]
				} else if !hasDivider {
					outCorner = [.bottom]
				}

				let isSelected = filter == selectedFilter

				next += 1

				return YPModels.YPCellModel(
					type: .checkmarkType,
					title: filter.description,
					description: "",
					hasDivider: hasDivider,
					outCorner: outCorner,
					isSelected: isSelected,
					event: nil
				)
			}
			viewData = .showFilters(viewModel)
		}

		viewController?.render(viewModel: viewData)
	}
}
