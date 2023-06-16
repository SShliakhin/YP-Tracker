import Foundation
import CoreData

// swiftlint:disable missing_docs
extension TrackerCategoryCD {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCategoryCD> {
		return NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
	}

	@NSManaged public var categoryID: UUID?
	@NSManaged public var title: String?
	@NSManaged public var trackers: NSOrderedSet?
}

// MARK: Generated accessors for trackers
extension TrackerCategoryCD {

	@objc(insertObject:inTrackersAtIndex:)
	@NSManaged public func insertIntoTrackers(_ value: TrackerCD, at idx: Int)

	@objc(removeObjectFromTrackersAtIndex:)
	@NSManaged public func removeFromTrackers(at idx: Int)

	@objc(insertTrackers:atIndexes:)
	@NSManaged public func insertIntoTrackers(_ values: [TrackerCD], at indexes: NSIndexSet)

	@objc(removeTrackersAtIndexes:)
	@NSManaged public func removeFromTrackers(at indexes: NSIndexSet)

	@objc(replaceObjectInTrackersAtIndex:withObject:)
	@NSManaged public func replaceTrackers(at idx: Int, with value: TrackerCD)

	@objc(replaceTrackersAtIndexes:withTrackers:)
	@NSManaged public func replaceTrackers(at indexes: NSIndexSet, with values: [TrackerCD])

	@objc(addTrackersObject:)
	@NSManaged public func addToTrackers(_ value: TrackerCD)

	@objc(removeTrackersObject:)
	@NSManaged public func removeFromTrackers(_ value: TrackerCD)

	@objc(addTrackers:)
	@NSManaged public func addToTrackers(_ values: NSOrderedSet)

	@objc(removeTrackers:)
	@NSManaged public func removeFromTrackers(_ values: NSOrderedSet)
}

extension TrackerCategoryCD: Identifiable {}
// swiftlint:enable missing_docs
