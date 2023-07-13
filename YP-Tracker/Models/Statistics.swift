import Foundation

struct StatisticsItem {
	let description: String
	let value: Int
}

enum StatisticsType: CustomStringConvertible {
	case bestPeriod([String: Int])
	case idealDays([String])
	case completedTrackers(Int)
	case averageValue([String: Int])

	var description: String {
		switch self {
		case .bestPeriod:
			return Appearance.bestPeriodTitle
		case .idealDays:
			return Appearance.idealDaysTitle
		case .completedTrackers:
			return Appearance.completedTrackersTitle
		case .averageValue:
			return Appearance.averageValueTitle
		}
	}

	var value: Int {
		switch self {
		case .bestPeriod(let dictionary):
			guard !dictionary.isEmpty else { return .zero }
			let days = dictionary.keys.sorted()
			return maxContinuousDays(dates: days)

		case .idealDays(let days):
			return days.count

		case .completedTrackers(let count):
			return count

		case .averageValue(let dictionary):
			guard !dictionary.isEmpty else { return .zero }
			let count = dictionary.count
			let sum = dictionary.values.reduce(0, +)
			return sum / count
		}
	}

	private func maxContinuousDays(dates: [String]) -> Int {
		var maxDays = 1
		var currentDays = 1

		for index in 1..<dates.count {
			guard
				let previousDate = Theme.dateFormatterStatistics.date(from: dates[index - 1]),
				let currentDate = Theme.dateFormatterStatistics.date(from: dates[index])
			else { return .zero }

			let difference = Calendar.current.dateComponents(
				[.day],
				from: previousDate,
				to: currentDate
			)
			if difference.day == 1 {
				currentDays += 1
				maxDays = max(maxDays, currentDays)
			} else {
				currentDays = 1
			}
		}

		return maxDays
	}
}

private extension StatisticsType {
	enum Appearance {
		static let bestPeriodTitle = "Лучший период"
		static let idealDaysTitle = "Идеальные дни"
		static let completedTrackersTitle = "Трекеров завершено"
		static let averageValueTitle = "Среднее значение"
	}
}
