import Foundation

protocol ICreateEditTrackerPresenter {
	/// Подготавливает данные на редринг вьюконтроллеру
	func present(data: CreateEditTrackerModels.Response)
}

final class CreateEditTrackerPresenter: ICreateEditTrackerPresenter {
	weak var viewController: ICreateEditTrackerViewController?
	private var hasSchedule = false

	typealias Section = CreateEditTrackerModels.ViewModel.Section

	func present(data: CreateEditTrackerModels.Response) {

		switch data {
		case let .update(hasSchedule, title, components, isSaveEnabled):

			self.hasSchedule = hasSchedule
			let newComponents = getNewComponents(
				hasSchedule: hasSchedule,
				components: components
			)

			viewController?.render(
				viewModel: .showAllComponents(
					hasSchedule: hasSchedule,
					title: title,
					components: newComponents,
					isSaveEnabled: isSaveEnabled
				)
			)
		case let .updateSection(section, items, isSaveEnabled):
			let newItems: Section

			switch items {
			case let .category(category):
				newItems = getNewCategorySection(
					category,
					title: items.description
				)
			case let .schedule(schedule):
				newItems = getNewCategorySection(
					schedule,
					title: items.description
				)
			case let .emoji(array, item):
				newItems = .emoji(
					array.map {
						.init(title: $0, isSelected: $0 == item)
					}
				)
			case let .color(array, item):
				newItems = .color(
					array.map {
						.init(title: $0, isSelected: $0 == item)
					}
				)
			}

			viewController?.render(
				viewModel: .showNewSection(
					section: section,
					items: newItems,
					isSaveEnabled: isSaveEnabled
				)
			)
		case let .updateSaveEnabled(isSaveEnabled):
			viewController?.render(
				viewModel: .showSaveEnabled(
					isSaveEnabled: isSaveEnabled
				)
			)
		}
	}
}

private extension CreateEditTrackerPresenter {
	func getNewComponents(
		hasSchedule: Bool,
		components: [CreateEditTrackerModels.Response.Section]
	) -> [Section] {
		var newComponents: [Section] = []

		for item in components {
			switch item {
			case let .category(category):
				newComponents.append(
					getNewCategorySection(
						category,
						title: item.description
					)
				)
			case let .schedule(schedule):
				newComponents.append(
					getNewScheduleSection(
						schedule,
						title: item.description
					)
				)
			case let .emoji(emojis, item):
				newComponents.append(
					.emoji(
						emojis.map {
							.init(title: $0, isSelected: $0 == item)
						}
					)
				)
			case let .color(colors, item):
				newComponents.append(
					.color(
						colors.map {
							.init(title: $0, isSelected: $0 == item)
						}
					)
				)
			}
		}
		return newComponents
	}

	func getNewCategorySection(_ category: String, title: String) -> Section {
		.category(
			.init(
				type: .chevronType,
				title: title,
				description: category,
				hasDivider: hasSchedule,
				outCorner: hasSchedule ? [.top] : [.all],
				isSelected: false,
				event: nil
			)
		)
	}

	func getNewScheduleSection(_ schedule: String, title: String) -> Section {
		.schedule(
			.init(
				type: .chevronType,
				title: title,
				description: schedule,
				hasDivider: false,
				outCorner: [.bottom],
				isSelected: false,
				event: nil
			)
		)
	}
}
