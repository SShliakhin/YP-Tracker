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
			return Theme.Texts.StatisticsTypes.bestPeriodTitle
		case .idealDays:
			return Theme.Texts.StatisticsTypes.idealDaysTitle
		case .completedTrackers:
			return Theme.Texts.StatisticsTypes.completedTrackersTitle
		case .averageValue:
			return Theme.Texts.StatisticsTypes.averageValueTitle
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
