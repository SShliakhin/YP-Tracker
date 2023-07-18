import Foundation

typealias ScreensTitles = Theme.Texts.ScreensTitles
typealias CategoryNames = Theme.Texts.CategoryNames
typealias TrackerNames = Theme.Texts.TrackerNames
typealias ActionsNames = Theme.Texts.ActionsNames

extension Theme {
	enum DynamicText {
		static func daysCount(count: Int) -> String {
			let formatString = NSLocalizedString(
				"days",
				comment: "Количество дней - плюрализм"
			)
			return String.localizedStringWithFormat(formatString, count)
		}
	}

	enum Texts {
		// MARK: - Actions Names
		enum ActionsNames {
			static var menuTrackerPin: String {
				NSLocalizedString(
					"menu.commonTitle.pin",
					comment: "Заголовок для меню: Закрепить"
				)
			}
			static var menuTrackerUnpin: String {
				NSLocalizedString(
					"menu.commonTitle.unpin",
					comment: "Заголовок для меню: Открепить"
				)
			}
			static var menuEdit: String {
				NSLocalizedString(
					"menu.commonTitle.edit",
					comment: "Заголовок для меню: Редактировать"
				)
			}
			static var menuDelete: String {
				NSLocalizedString(
					"menu.commonTitle.delete",
					comment: "Заголовок для меню: Удалить"
				)
			}
			static var deleteButtonTitle: String {
				NSLocalizedString(
					"button.commonTitle.delete",
					comment: "Заголовок для кнопки: Удалить"
				)
			}
			static var cancelButtonTitle: String {
				NSLocalizedString(
					"button.commonTitle.cancel",
					comment: "Заголовок для кнопки: Отменить"
				)
			}
			static var readyButtonTitle: String {
				NSLocalizedString(
					"button.commonTitle.ready",
					comment: "Заголовок для кнопки: Готово"
				)
			}
			static var createButtonTitle: String {
				NSLocalizedString(
					"button.commonTitle.create",
					comment: "Заголовок для кнопки: Создать"
				)
			}
			static var saveButtonTitle: String {
				NSLocalizedString(
					"button.commonTitle.save",
					comment: "Заголовок для кнопки: Сохранить"
				)
			}
		}
		// MARK: - Messages
		enum Messages {
			static var emptySearchListMessage: String {
				NSLocalizedString(
					"empty.searchList.message",
					comment: "Сообщение при неудачном поиске по текстовому шаблону"
				)
			}
			static var emptyTrackersListMessage: String {
				NSLocalizedString(
					"empty.trackersList.message",
					comment: "Сообщение при отсутствие трекеров в базе"
				)
			}
			static var emptyCategoriesListMessage: String {
				NSLocalizedString(
					"empty.categoriesList.message",
					comment: "Сообщение при отсутствие категорий в базе"
				)
			}
			static var emptyStatisticsListMessage: String {
				NSLocalizedString(
					"empty.statisticsList.message",
					comment: "Сообщение при отсутствие статистики в базе"
				)
			}
		}
		// MARK: - Tracker Names
		enum TrackerNames {
			static var habit: String {
				NSLocalizedString(
					"tracker.type.habit",
					comment: "Тип трекера: Привычка"
				)
			}
			static var event: String {
				NSLocalizedString(
					"tracker.type.event",
					comment: "Тип трекера: Нерегулярное событие"
				)
			}
			static var filtersButtonTitle: String {
				NSLocalizedString(
					"tracker.filters.buttonTitle",
					comment: "Заголовок для кнопки: Фильтры"
				)
			}
			static var searchPlaceholder: String {
				NSLocalizedString(
					"tracker.search.placeholder",
					comment: "Плейсхолдер для ввода строки поиска"
				)
			}
			static var deleteRequestMessage: String {
				NSLocalizedString(
					"tracker.requestDelete.message",
					comment: "Запрос-сообщение на удаление трекера"
				)
			}
			static var textFieldPlaceholder: String {
				NSLocalizedString(
					"tracker.inputTitle.placeholder",
					comment: "Плейсхолдер для ввода заголовка трекера"
				)
			}
			static var titleLimitMessage: String {
				NSLocalizedString(
					"tracker.errorTitle.overLimit38Characters",
					comment: "Превышение лимита в 38 символов при вводе заголовка трекера"
				)
			}
		}
		// MARK: - Category Names
		enum CategoryNames {
			static var pinnedCategoryTitle: String {
				NSLocalizedString(
					"category.pinnedTrackers.title",
					comment: "Название категории с закрепленными трекерами"
				)
			}
			static var addCategoryButtonTitle: String {
				NSLocalizedString(
					"category.add.buttonTitle",
					comment: "Заголовок для кнопки: Добавить категорию"
				)
			}
			static var deleteRequestMessage: String {
				NSLocalizedString(
					"category.requestDelete.message",
					comment: "Запрос-сообщение на удаление категории"
				)
			}
			static var textFieldPlaceholder: String {
				NSLocalizedString(
					"category.inputTitle.placeholder",
					comment: "Плейсхолдер для ввода заголовка категории"
				)
			}
			static var titleLimitMessage: String {
				NSLocalizedString(
					"category.errorTitle.overLimit24Characters",
					comment: "Превышение лимита в 24 символа при вводе заголовка категории"
				)
			}
		}
		// MARK: - Tracker Filter Names
		enum TrackerFilterNames {
			static var all: String {
				NSLocalizedString(
					"tracker.filterAll.title",
					comment: "Название фильтра: Все"
				)
			}
			static var today: String {
				NSLocalizedString(
					"tracker.filterToday.title",
					comment: "Название фильтра: Сегодня"
				)
			}
			static var completed: String {
				NSLocalizedString(
					"tracker.filterCompleted.title",
					comment: "Название фильтра: Завершенные"
				)
			}
			static var uncompleted: String {
				NSLocalizedString(
					"tracker.filterUncompleted.title",
					comment: "Название фильтра: Не завершенные"
				)
			}
		}
		// MARK: - Tracker Sections Names
		enum TrackerSectionsNames {
			static var categoryTitle: String {
				NSLocalizedString(
					"section.category.title",
					comment: "Заголовок секции Категория"
				)
			}
			static var scheduleTitle: String {
				NSLocalizedString(
					"section.schedule.title",
					comment: "Заголовок секции Расписание"
				)
			}
			static var emojiTitle: String {
				NSLocalizedString(
					"section.emoji.title",
					comment: "Заголовок секции Emoji"
				)
			}
			static var colorTitle: String {
				NSLocalizedString(
					"section.color.title",
					comment: "Заголовок секции Цвет"
				)
			}
		}
		// MARK: - Schedule Names
		enum ScheduleNames {
			static var everyDay: String {
				NSLocalizedString(
					"schedule.everyDay.description",
					comment: "Вариант описания расписания: Каждый день"
				)
			}
		}
		// MARK: - Onboarding Pages
		enum OnboardingPages {
			static var blueTextValue: String {
				NSLocalizedString(
					"onboarding.bluePage.text",
					comment: "Текст на голубой странице онбординга"
				)
			}
			static var redTextValue: String {
				NSLocalizedString(
					"onboarding.redPage.text",
					comment: "Текст на красной странице онбординга"
				)
			}
			static var buttonTitle: String {
				NSLocalizedString(
					"onboarding.button.title",
					comment: "Заголовок для кнопки прекращения онбординга"
				)
			}
		}
		// MARK: - Tab Titles
		enum TabTitles {
			static var trackersTabTitle: String {
				NSLocalizedString(
					"trackers.tabbarItem.title",
					comment: "Заголовок для элемента таббар: Трекеры"
				)
			}
			static var statisticsTabTitle: String {
				NSLocalizedString(
					"statistics.tabbarItem.title",
					comment: "Заголовок для элемента таббар: Статистика"
				)
			}
		}
		// MARK: - Statistics Types
		enum StatisticsTypes {
			static var bestPeriodTitle: String {
				NSLocalizedString(
					"statistics.bestPeriod.title",
					comment: "Заголовок статистики: Лучший период"
				)
			}
			static var idealDaysTitle: String {
				NSLocalizedString(
					"statistics.idealDays.title",
					comment: "Заголовок статистики: Идеальные дни"
				)
			}
			static var completedTrackersTitle: String {
				NSLocalizedString(
					"statistics.completedTrackers.title",
					comment: "Заголовок статистики: Трекеров завершено"
				)
			}
			static var averageValueTitle: String {
				NSLocalizedString(
					"statistics.averageValue.title",
					comment: "Заголовок статистики: Среднее значение"
				)
			}
		}
		// MARK: - Screens Titles
		enum ScreensTitles {
			static var titleTrackersVC: String {
				NSLocalizedString(
					"vc.trackers.title",
					comment: "Заголовок экрана Трекеры"
				)
			}
			static var titleFiltersVC: String {
				NSLocalizedString(
					"vc.filters.title",
					comment: "Заголовок экрана Фильтры"
				)
			}
			static var titleSelectTrackerTypeVC: String {
				NSLocalizedString(
					"vc.selectTrackerType.title",
					comment: "Заголовок экрана Создание трекера"
				)
			}
			static var titleStatisticsVC: String {
				NSLocalizedString(
					"vc.statistics.title",
					comment: "Заголовок экрана Статистика"
				)
			}
			static var titleHabitVC: String {
				NSLocalizedString(
					"vc.newHabit.title",
					comment: "Заголовок экрана Новая привычка"
				)
			}
			static var titleEventVC: String {
				NSLocalizedString(
					"vc.newEvent.title",
					comment: "Заголовок экрана Новое нерегулярное событие"
				)
			}
			static var titleCategoryVC: String {
				NSLocalizedString(
					"vc.selectCategory.title",
					comment: "Заголовок экрана Категория"
				)
			}
			static var titleScheduleVC: String {
				NSLocalizedString(
					"vc.selectSchedule.title",
					comment: "Заголовок экрана Расписание"
				)
			}
			static var titleAddCategoryVC: String {
				NSLocalizedString(
					"vc.newCategory.title",
					comment: "Заголовок экрана Новая категория"
				)
			}
			static var titleEditCategoryVC: String {
				NSLocalizedString(
					"vc.editCategory.title",
					comment: "Заголовок экрана Редактирование категории"
				)
			}
			static var titleEditTrackerVC: String {
				NSLocalizedString(
					"vc.editTracker.title",
					comment: "Заголовок экрана Редактирование привычки"
				)
			}
			static var defaultTitle: String {
				NSLocalizedString(
					"vc.default.title",
					comment: "Заголовок экрана по умолчанию"
				)
			}
		}
	}
}
