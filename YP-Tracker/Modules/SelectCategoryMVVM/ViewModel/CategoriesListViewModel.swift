import Foundation

enum CategoriesListEvents {
	case showCreateEditCategory
	case selectCategory(UUID, String)
}

protocol CategoriesListViewModelInput: AnyObject {
	var didSendEventClosure: ((CategoriesListEvents) -> Void)? { get set }

	func viewIsReady()
	func update()
	func didSelectItemAtIndex(_ index: Int)
	func didTapAddCategoryButton()
}

protocol CategoriesListViewModelOutput: AnyObject {
	var items: Observable<[CategoriesListItemViewModel]> { get }
	var numberOfItems: Int { get }
	var isEmpty: Bool { get }

	func itemAtIndex(_ index: Int) -> CategoriesListItemViewModel
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
	func itemAtIndex(_ index: Int) -> CategoriesListItemViewModel {
		items.value[index]
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

	func update() {
		viewIsReady()
	}

	func didSelectItemAtIndex(_ index: Int) {
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
	}

	func didTapAddCategoryButton() {
		didSendEventClosure?(.showCreateEditCategory)
	}
}

private extension DefaultCategoriesListViewModel {
	func createItem(index: Int, isSelected: Bool) -> CategoriesListItemViewModel {
		let all = categories.count
		return CategoriesListItemViewModel(
			category: categories[index],
			first: index == 0,
			last: index == all - 1,
			isSelected: isSelected,
			event: nil
		)
	}
}
