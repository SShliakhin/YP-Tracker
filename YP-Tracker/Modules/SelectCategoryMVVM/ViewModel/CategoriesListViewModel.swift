import Foundation

enum CategoriesListEvents {
	case addCategory
	case selectCategory(UUID, String)
}

enum CategoriesListRequest {
	case selectItemAtIndex(_ index: Int)
	case tapActionButton
	case updateView
}

protocol CategoriesListViewModelInput: AnyObject {
	var didSendEventClosure: ((CategoriesListEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: CategoriesListRequest)
}

protocol CategoriesListViewModelOutput: AnyObject {
	var items: Observable<[CategoriesListItemViewModel]> { get }
	var numberOfItems: Int { get }
	var isEmpty: Bool { get }

	func cellModelAtIndex(_ index: Int) -> YPCellModel
}

typealias CategoriesListViewModel = (
	CategoriesListViewModelInput &
	CategoriesListViewModelOutput
)

final class DefaultCategoriesListViewModel: CategoriesListViewModel {
	// MARK: - INPUT
	var didSendEventClosure: ((CategoriesListEvents) -> Void)?

	// MARK: - OUTPUT
	var items: Observable<[CategoriesListItemViewModel]> = Observable([])
	var numberOfItems: Int { items.value.count }
	var isEmpty: Bool { items.value.isEmpty }

	private let categoriesProvider: ICategoriesProvider
	private let trackerAction: Tracker.Action

	private var selectedItemIndex: Int?
	private var categories: [TrackerCategory] = []

	// MARK: - Inits

	init(
		dep: IYPModuleDependency,
		trackerAction: Tracker.Action
	) {
		self.trackerAction = trackerAction
		self.categoriesProvider = dep.categoriesProvider
	}
}

// MARK: - OUTPUT

extension DefaultCategoriesListViewModel {
	func cellModelAtIndex(_ index: Int) -> YPCellModel {
		let item = items.value[index]

		let all = categories.count
		let first = index == 0
		let last = index == all - 1

		let outCorner: [CellCorner]
		switch (first, last) {
		case (true, true):
			outCorner = [.all]
		case (true, false):
			outCorner = [.top]
		case (false, true):
			outCorner = [.bottom]
		default:
			outCorner = []
		}

		return YPCellModel(
			type: .checkmarkType,
			title: item.title,
			description: "",
			hasDivider: !last,
			outCorner: outCorner,
			isSelected: item.isSelected,
			event: nil
		)
	}
}

// MARK: - INPUT. View event methods

extension DefaultCategoriesListViewModel {
	func viewIsReady() {
		if case let .selectCategory(categoryID) = trackerAction {
			categories = categoriesProvider.getCategories()

			items.value = categories.enumerated().map { keyValue in
				if keyValue.element.id == categoryID {
					selectedItemIndex = keyValue.offset
				}
				return createItem(
					index: keyValue.offset,
					isSelected: keyValue.element.id == categoryID
				)
			}
		}
	}

	func didUserDo(request: CategoriesListRequest) {
		switch request {
		case .updateView:
			viewIsReady()
		case let .selectItemAtIndex(index):
			let category = categories[index]
			if
				let selectedItemIndex = selectedItemIndex,
				selectedItemIndex != index
			{
				items.value[selectedItemIndex] = createItem(
					index: selectedItemIndex,
					isSelected: false
				)
				items.value[index] = createItem(
					index: index,
					isSelected: true
				)
				self.selectedItemIndex = index
			} else {
				selectedItemIndex = index
				items.value[index] = createItem(
					index: index,
					isSelected: true
				)
			}
			didSendEventClosure?(.selectCategory(category.id, category.title))
		case .tapActionButton:
			didSendEventClosure?(.addCategory)
		}
	}
}

private extension DefaultCategoriesListViewModel {
	func createItem(index: Int, isSelected: Bool) -> CategoriesListItemViewModel {
		CategoriesListItemViewModel(
			category: categories[index],
			isSelected: isSelected
		)
	}
}
