import XCTest
import SnapshotTesting
@testable import YP_Tracker

final class YPTrackerTests: XCTestCase {
	private let mainVC: UIViewController = Di().makeTrackersModule().0

	func testDarkMainVC_shouldBeFail() {
		// mainVC.overrideUserInterfaceStyle = .light // после создания образца раскоментировать
		assertSnapshot(
			matching: mainVC,
			as: .image(traits: .init(userInterfaceStyle: .dark))
		)
	}

	func testLightMainVC_shouldBeFail() {
		// mainVC.overrideUserInterfaceStyle = .dark // после создания образца раскоментировать
		assertSnapshot(
			matching: mainVC,
			as: .image(traits: .init(userInterfaceStyle: .light))
		)
	}
}
