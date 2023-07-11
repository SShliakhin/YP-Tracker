import XCTest
import SnapshotTesting
@testable import YP_Tracker

final class YPTrackerTests: XCTestCase {
	func testMainVC_shouldBeSuccess() {
		let mainVC: UIViewController = Di().makeTrackersModule().0

		assertSnapshot(
			matching: mainVC,
			as: .image(traits: .init(userInterfaceStyle: .light))
		)
		assertSnapshot(
			matching: mainVC,
			as: .image(traits: .init(userInterfaceStyle: .dark))
		)
	}
}
