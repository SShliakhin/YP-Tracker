//
//  ICreateEditTrackerPresenter.swift
import Foundation

protocol ICreateEditTrackerPresenter {
	/// Подготавливает данные на редринг вьюконтроллеру
	func present(data: CreateEditTrackerModels.Response)
}

final class CreateEditTrackerPresenter: ICreateEditTrackerPresenter {
	weak var viewController: ICreateEditTrackerViewController?

	func present(data: CreateEditTrackerModels.Response) {

		let viewData: CreateEditTrackerModels.ViewModel

//		switch data {
//		case let .selectFilter(selectedFilter, allFilters):
//			let all = allFilters.count
//			var next = 1
//
//			let viewModel: [CreateEditTrackerModels.YPCellModel] = allFilters.map { filter in
//				let (hasDivider, outCorner) = getDecor(all: all, next: next)
//				let isSelected = filter == selectedFilter
//
//				next += 1
//				return CreateEditTrackerModels.YPCellModel(
//					type: .checkmarkType,
//					title: filter.description,
//					description: "",
//					hasDivider: hasDivider,
//					outCorner: outCorner,
//					isSelected: isSelected,
//					event: nil
//				)
//			}
//			viewData = .showFilters(viewModel)
//		}
//
//		viewController?.render(viewModel: viewData)
	}
}

private extension CreateEditTrackerPresenter {
	func getDecor(all: Int, next: Int) -> (hasDivider: Bool, outCorner: [CellCorner]) {
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
