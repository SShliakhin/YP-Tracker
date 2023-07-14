import Foundation

enum StatisticsListEvents {}

enum StatisticsListRequest {
	case updateView
}

protocol StatisticsListViewModelInput: AnyObject {
	var didSendEventClosure: ((StatisticsListEvents) -> Void)? { get set }

	func viewIsReady()
	func didUserDo(request: StatisticsListRequest)
}

protocol StatisticsListViewModelOutput: AnyObject {
	var items: Observable<[StatisticsListItemViewModel]> { get }
	var numberOfItems: Int { get }
	var isEmpty: Bool { get }

	func cellModelAtIndex(_ index: Int) -> StatisticsCellModel
}

typealias StatisticsListViewModel = (
	StatisticsListViewModelInput &
	StatisticsListViewModelOutput
)

final class DefaultStatisticsListViewModel: StatisticsListViewModel {
	// MARK: - INPUT
	var didSendEventClosure: ((StatisticsListEvents) -> Void)?

	// MARK: - OUTPUT
	var items: Observable<[StatisticsListItemViewModel]> = Observable([])
	var numberOfItems: Int { items.value.count }
	var isEmpty: Bool { items.value.isEmpty }

	private let statisticsService: StatisticsOut
	private var statisticsItems: [StatisticsItem] = []

	init(
		dep: IStatisticsModuleDependency
	) {
		self.statisticsService = dep.statisticsOut
	}
}

// MARK: - OUTPUT

extension DefaultStatisticsListViewModel {
	func cellModelAtIndex(_ index: Int) -> StatisticsCellModel {
		let item = items.value[index]

		return StatisticsCellModel(
			title: item.title,
			description: item.description
		)
	}
}

// MARK: - INPUT. View event methods

extension DefaultStatisticsListViewModel {
	func viewIsReady() {
		statisticsItems = statisticsService.statistics
		guard !statisticsItems
				.allSatisfy({ $0.value == 0 })
		else { return }

		items.value = statisticsItems.map { item in
				.init(
					title: "\(item.value)",
					description: item.description
				)
		}
	}

	func didUserDo(request: StatisticsListRequest) {
		switch request {
		case .updateView:
			viewIsReady()
		}
	}
}
