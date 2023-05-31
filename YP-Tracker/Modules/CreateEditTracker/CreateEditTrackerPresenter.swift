import Foundation

protocol ICreateEditTrackerPresenter {
	/// Подготавливает данные на редринг вьюконтроллеру
	func present(data: CreateEditTrackerModels.Response)
}

final class CreateEditTrackerPresenter: ICreateEditTrackerPresenter {
	weak var viewController: ICreateEditTrackerViewController?

	typealias Section = CreateEditTrackerModels.ViewModel.Section

	func present(data: CreateEditTrackerModels.Response) {

		switch data {
		case let .update(hasSchedule, title, components, isSaveEnabled):

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
			case .category:
				return
			case .schedule:
				return
			case let .emoji(array, item):
				newItems = .emoji(array.map { .init(title: $0, isSelected: $0 == item) })
			case let .color(array, item):
				newItems = .color(array.map { .init(title: $0, isSelected: $0 == item) })
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
					.category(
						.init(
							type: .chevronType,
							title: item.description,
							description: category,
							hasDivider: hasSchedule,
							outCorner: hasSchedule ? [.top] : [.all],
							isSelected: false,
							event: nil
						)
					)
				)
			case let .schedule(schedule):
				newComponents.append(
					.schedule(
						.init(
							type: .chevronType,
							title: item.description,
							description: schedule,
							hasDivider: false,
							outCorner: [.bottom],
							isSelected: false,
							event: nil
						)
					)
				)
			case let .emoji(emojis, item):
				newComponents.append(
					.emoji(
						emojis.map { .init(title: $0, isSelected: $0 == item) }
					)
				)
			case let .color(colors, item):
				newComponents.append(
					.color(
						colors.map { .init( title: $0, isSelected: $0 == item) }
					)
				)
			}
		}
		return newComponents
	}
}
