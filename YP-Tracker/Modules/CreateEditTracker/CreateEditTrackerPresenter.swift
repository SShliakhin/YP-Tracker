import Foundation

protocol ICreateEditTrackerPresenter {
	/// Подготавливает данные на редринг вьюконтроллеру
	func present(data: CreateEditTrackerModels.Response)
}

final class CreateEditTrackerPresenter: ICreateEditTrackerPresenter {
	weak var viewController: ICreateEditTrackerViewController?
	private var hasSchedule = false

	typealias Section = CreateEditTrackerModels.ViewModel.Section

	// swiftlint:disable:next function_body_length
	func present(data: CreateEditTrackerModels.Response) {

		switch data {
		case let .update(updateBox):

			self.hasSchedule = updateBox.hasSchedule
			let newComponents = getNewComponents(
				hasSchedule: hasSchedule,
				components: updateBox.components
			)

			let saveTitle = updateBox.isNewTracker
			? Appearance.titleCreate
			: Appearance.titleSave

			let totalCompletionsString = updateBox.totalCompletions == 0
			? ""
			: Theme.Localizable.daysCount(count: updateBox.totalCompletions)

			let update = CreateEditTrackerModels.ViewModel.UpdateBox(
				hasSchedule: updateBox.hasSchedule,
				title: updateBox.title,
				components: newComponents,
				isSaveEnabled: updateBox.isSaveEnabled,
				saveTitle: saveTitle,
				totalCompletionsString: totalCompletionsString
			)

			viewController?.render(viewModel: .showAllComponents(update))

		case let .updateSection(section, items, isSaveEnabled):
			let newItems: Section

			switch items {
			case let .category(category):
				newItems = getNewCategorySection(
					category,
					title: items.description
				)
			case let .schedule(schedule):
				newItems = getNewScheduleSection(
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

// MARK: - Appearance
private extension CreateEditTrackerPresenter {
	enum Appearance {
		static let titleCreate = NSLocalizedString(
			"button.commonTitle.create",
			comment: "Заголовок для кнопки: Создать"
		)
		static let titleSave = NSLocalizedString(
			"button.commonTitle.save",
			comment: "Заголовок для кнопки: Сохранить"
		)
	}
}
