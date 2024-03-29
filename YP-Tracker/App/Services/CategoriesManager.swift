import Foundation

struct TrackerEditBox {
	let tracker: Tracker
	let categoryID: UUID
	let categoryTitle: String
	let totalTrackerCompletions: Int
}

protocol ICategoriesManager: AnyObject {
	func getCategories() -> [TrackerCategory]
	func getTrackers() -> [Tracker]
	func getCompletedTrackers() -> [TrackerRecord]
	func getTrackerEditBoxByID(_ trackerID: UUID) -> TrackerEditBox?

	func addCategory(title: String)
	func editCategoryBy(categoryID: UUID, newtitle: String)
	func removeCategoryBy(categoryID: UUID)
	func addTracker(tracker: Tracker, categoryID: UUID)
	func editTracker(tracker: Tracker, categoryID: UUID)
	func removeTrackerBy(trackerID: UUID)
	func addCompletedTracker(trackerID: UUID, date: Date)
	func cancelCompletedTracker(trackerID: UUID, date: Date)
	func pinUnpinTracker(_ tracker: Tracker)
}

final class CategoriesManager {
	private var trackers: [Tracker]
	private var categories: [TrackerCategory]
	private var completedTrackers: [TrackerRecord]

	init(
		trackers: [Tracker],
		categories: [TrackerCategory],
		completedTrackers: [TrackerRecord]
	) {
		self.trackers = trackers
		self.categories = categories
		self.completedTrackers = completedTrackers
	}
}

// MARK: - ICategoriesManager

extension CategoriesManager: ICategoriesManager {
	func getCategories() -> [TrackerCategory] {
		categories
	}

	func getTrackers() -> [Tracker] {
		trackers
	}

	func getCompletedTrackers() -> [TrackerRecord] {
		completedTrackers
	}

	func getTrackerEditBoxByID(_ trackerID: UUID) -> TrackerEditBox? {
		guard let trackerIndex = trackers.firstIndex(where: { $0.id == trackerID }) else { return nil }
		guard let categoryIndex = getCategoryIndexByTrackerId(trackerID) else { return nil }

		let category = categories[categoryIndex]
		let totalCompletions = completedTrackers
			.filter { $0.trackerId == trackerID }
			.count

		return TrackerEditBox(
			tracker: trackers[trackerIndex],
			categoryID: category.id,
			categoryTitle: category.title,
			totalTrackerCompletions: totalCompletions
		)
	}

	func addCategory(title: String) {
		categories.append(
			TrackerCategory(
				id: UUID(),
				title: title,
				trackers: []
			)
		)
	}

	func editCategoryBy(categoryID: UUID, newtitle: String) {
		guard let categoryIndex = categories.firstIndex(where: { category in
			category.id == categoryID
		}) else { return }

		let newCategory = TrackerCategory(
			id: categoryID,
			title: newtitle,
			trackers: categories[categoryIndex].trackers
		)
		categories[categoryIndex] = newCategory
	}

	func removeCategoryBy(categoryID: UUID) {
		guard let category = categories.first(where: { $0.id == categoryID }) else { return }

		let trackersID = category.trackers
		if !trackersID.isEmpty {
			removeTrackersBy(trackersID: trackersID)
		}
		categories.removeAll { $0.id == categoryID }
	}

	func addTracker(tracker: Tracker, categoryID: UUID) {
		guard let categoryIndex = categories.firstIndex(where: { category in
			category.id == categoryID
		}) else { return }

		var categoryTrackers = categories[categoryIndex].trackers
		categoryTrackers.append(tracker.id)

		categories[categoryIndex] = createNewCategory(old: categories[categoryIndex], trackers: categoryTrackers)

		trackers.append(tracker)
	}

	func editTracker(tracker: Tracker, categoryID: UUID) {
		guard let trackerIndex = trackers.firstIndex(where: { item in
			item.id == tracker.id
		}) else { return }

		trackers[trackerIndex] = tracker

		guard let categoryIndex = categories.firstIndex(where: { category in
			category.id == categoryID
		}) else { return }

		guard let oldCategoryIndex = getCategoryIndexByTrackerId(tracker.id) else { return }

		if categoryIndex == oldCategoryIndex { return }

		var categoryTrackers = categories[categoryIndex].trackers
		categoryTrackers.append(tracker.id)

		categories[categoryIndex] = createNewCategory(old: categories[categoryIndex], trackers: categoryTrackers)

		categoryTrackers = categories[oldCategoryIndex].trackers
		categoryTrackers.removeAll(where: { id in
			id == tracker.id
		})

		categories[oldCategoryIndex] = createNewCategory(old: categories[oldCategoryIndex], trackers: categoryTrackers)
	}

	func removeTrackerBy(trackerID: UUID) {
		trackers.removeAll { tracker in
			tracker.id == trackerID
		}
		completedTrackers.removeAll { record in
			record.trackerId == trackerID
		}

		guard let categoryIndex = getCategoryIndexByTrackerId(trackerID) else { return }

		var categoryTrackers = categories[categoryIndex].trackers
		categoryTrackers.removeAll(where: { id in
			id == trackerID
		})
		categories[categoryIndex] = createNewCategory(
			old: categories[categoryIndex],
			trackers: categoryTrackers
		)
	}

	func addCompletedTracker(trackerID: UUID, date: Date) {
		completedTrackers.append(
			TrackerRecord(
				trackerId: trackerID,
				date: date
			)
		)
	}

	func cancelCompletedTracker(trackerID: UUID, date: Date) {
		guard let completedTrackerIndex = completedTrackers.firstIndex(where: { record in
			let isTheSameDay = Calendar.current.isDate(record.date, inSameDayAs: date)
			return (record.trackerId == trackerID) && isTheSameDay
		}) else { return }
		completedTrackers.remove(at: completedTrackerIndex)
	}

	private func createNewCategory(old: TrackerCategory, trackers: [UUID]) -> TrackerCategory {
		TrackerCategory(
			id: old.id,
			title: old.title,
			trackers: trackers
		)
	}

	private func getCategoryIndexByTrackerId(_ trackerID: UUID) -> Int? {
		for (index, category) in categories.enumerated() {
			if category.trackers.firstIndex(where: { tracker in
				tracker == trackerID
			}) != nil { return index }
		}
		return nil
	}

	func pinUnpinTracker(_ tracker: Tracker) {
		guard let trackerIndex = trackers.firstIndex(where: { item in
			item.id == tracker.id
		}) else { return }

		trackers[trackerIndex] = tracker
	}
}

private extension CategoriesManager {
	func removeTrackersBy(trackersID: [UUID]) {
		trackers = trackers
			.filter { !trackersID.contains($0.id) }
		completedTrackers = completedTrackers
			.filter { !trackersID.contains($0.trackerId) }
	}
}
