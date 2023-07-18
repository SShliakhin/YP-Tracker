import XCTest
import SnapshotTesting
@testable import YP_Tracker

final class YPTrackerTests: XCTestCase {
	func test_MainVC_shouldBeSuccess() {
		let sut: UIViewController = Di().makeTrackersModule().0

		assertSnapshot(
			matching: sut,
			as: .image(traits: .init(userInterfaceStyle: .light))
		)
		assertSnapshot(
			matching: sut,
			as: .image(traits: .init(userInterfaceStyle: .dark))
		)
	}
}
