import Foundation
import CoreData

// swiftlint:disable missing_docs
extension TrackerCD {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCD> {
		return NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
	}

	@NSManaged public var color: String?
	@NSManaged public var emoji: String?
	@NSManaged public var schedule: String?
	@NSManaged public var title: String?
	@NSManaged public var trackerID: UUID?
	@NSManaged public var pinned: Bool
	@NSManaged public var trackerCategory: TrackerCategoryCD?
	@NSManaged public var trackerRecords: NSSet?
}

// MARK: Generated accessors for trackerRecords
extension TrackerCD {

	@objc(addTrackerRecordsObject:)
	@NSManaged public func addToTrackerRecords(_ value: TrackerRecordCD)

	@objc(removeTrackerRecordsObject:)
	@NSManaged public func removeFromTrackerRecords(_ value: TrackerRecordCD)

	@objc(addTrackerRecords:)
	@NSManaged public func addToTrackerRecords(_ values: NSSet)

	@objc(removeTrackerRecords:)
	@NSManaged public func removeFromTrackerRecords(_ values: NSSet)
}

extension TrackerCD: Identifiable {}
// swiftlint:enable missing_docs
