import Foundation

protocol ICategoriesRepository {
	func getTrackers() -> [Tracker]
	func getCategories() -> [TrackerCategory]
	func getCompletedTrackers() -> [TrackerRecord]
}

final class TrackerCategoriesStub: ICategoriesRepository {

	private var trackers: [Tracker] = []

	init() {
		trackers = getInitialTrackers()
	}

	func getTrackers() -> [Tracker] {
		trackers
	}
	// swiftlint:disable:next function_body_length
	func getInitialTrackers() -> [Tracker] {
		[
			Tracker(
				id: UUID(),
				title: "Учиться делать iOS-приложения",
				emoji: "🤔",
				color: TrackerColor.red.rawValue,
				schedule: [
					1: false,
					2: true,
					3: true,
					4: true,
					5: true,
					6: true,
					7: false
				]
			),
			Tracker(
				id: UUID(),
				title: "Поливать растения",
				emoji: "🌺",
				color: TrackerColor.lightGreen.rawValue,
				schedule: [
					1: false,
					2: true,
					3: false,
					4: true,
					5: false,
					6: true,
					7: false
				]
			),
			Tracker(
				id: UUID(),
				title: "Кошка заслонила камеру на созвоне",
				emoji: "😻",
				color: TrackerColor.orange.rawValue,
				schedule: [:]
			),
			Tracker(
				id: UUID(),
				title: "Cвидания",
				emoji: "❤️",
				color: TrackerColor.lightBlue.rawValue,
				schedule: [
					1: false,
					2: false,
					3: false,
					4: false,
					5: false,
					6: true,
					7: false
				]
			),
			Tracker(
				id: UUID(),
				title: "Бабушка прислала открытку в вотсапе",
				emoji: "😇",
				color: TrackerColor.red.rawValue,
				schedule: [:]
			)
		]
	}
	// swiftlint:disable:next function_body_length
	func getCategories() -> [TrackerCategory] {
		[
			TrackerCategory(
				id: UUID(),
				title: "Важное",
				trackers: [
					trackers[0].id
				]
			),
			TrackerCategory(
				id: UUID(),
				title: "Домашний уют",
				trackers: [
					trackers[1].id
				]
			),
			TrackerCategory(
				id: UUID(),
				title: "Радостные мелочи",
				trackers: [
					trackers[2].id,
					trackers[3].id,
					trackers[4].id
				]
			),
			TrackerCategory(
				id: UUID(),
				title: "Самочувствие",
				trackers: []
			),
			TrackerCategory(
				id: UUID(),
				title: "Привычки",
				trackers: []
			),
			TrackerCategory(
				id: UUID(),
				title: "Внимательность",
				trackers: []
			),
			TrackerCategory(
				id: UUID(),
				title: "Спорт",
				trackers: []
			),
			TrackerCategory(
				id: UUID(),
				title: "Спорт 2",
				trackers: []
			),
			TrackerCategory(
				id: UUID(),
				title: "Спорт 3",
				trackers: []
			)
		]
	}

	func getCompletedTrackers() -> [TrackerRecord] {
		[
			TrackerRecord(
				trackerId: trackers[0].id,
				date: Date()
			)
		]
	}
}
