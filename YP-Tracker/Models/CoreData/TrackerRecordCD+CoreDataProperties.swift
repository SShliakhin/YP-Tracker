import Foundation
import CoreData

// swiftlint:disable missing_docs
extension TrackerRecordCD {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCD> {
		return NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
	}

	@NSManaged public var dateString: String?
	@NSManaged public var trackerID: UUID?
	@NSManaged public var tracker: TrackerCD?
}

extension TrackerRecordCD: Identifiable {}
// swiftlint:enable missing_docs
