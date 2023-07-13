import Foundation

protocol StatisticsOut {
	var statistics: [StatisticsItem] { get }
}

protocol StatisticsIn {
	func completeTracker(on date: Date, with allTrackersCount: Int)
	func uncompleteTracker(on date: Date)
	func addIdealDay(on date: Date)
	func deleteIdealDay(on date: Date)
}

final class StatisticsService {
	@UserDefaultsBacked(key: "completed-trackers-count")
	private var completedTrackers = 0

	@UserDefaultsBacked(key: "ideal-days")
	private var idealDays: [String] = []

	@UserDefaultsBacked(key: "day-trackers")
	private var dayTrackers: [String: Int] = [:]
}

// MARK: - StatisticsIn

extension StatisticsService: StatisticsIn {
	func completeTracker(on date: Date, with allTrackersCount: Int) {
		let dateString = Theme.dateFormatterStatistics.string(from: date)
		let newValue = dayTrackers[dateString, default: 0] + 1

		dayTrackers[dateString] = newValue

		if newValue >= allTrackersCount {
			addIdealDay(on: date)
		}

		completedTrackers += 1
	}

	func uncompleteTracker(on date: Date) {
		let dateString = Theme.dateFormatterStatistics.string(from: date)
		let newValue = dayTrackers[dateString, default: 0] - 1

		dayTrackers[dateString] = newValue <= 0
		? nil
		: newValue

		deleteIdealDay(on: date)

		completedTrackers -= 1
	}

	func addIdealDay(on date: Date) {
		let dateString = Theme.dateFormatterStatistics.string(from: date)

		var currentValue = idealDays
		if !currentValue.contains(dateString) {
			currentValue.append(dateString)
			idealDays = currentValue
		}
	}

	func deleteIdealDay(on date: Date) {
		let dateString = Theme.dateFormatterStatistics.string(from: date)

		var currentValue = idealDays
		if let index = currentValue.firstIndex(where: { $0 == dateString }) {
			currentValue.remove(at: index)
		}
		idealDays = currentValue
	}
}

// MARK: - StatisticsOut

extension StatisticsService: StatisticsOut {
	var statistics: [StatisticsItem] {
		let array: [StatisticsType] = [
			.bestPeriod(dayTrackers),
			.idealDays(idealDays),
			.completedTrackers(completedTrackers),
			.averageValue(dayTrackers)
		]
		return array.map {
			.init(
				description: $0.description,
				value: $0.value
			)
		}
	}
}
