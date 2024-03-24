import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    let vc = TrackersViewController(viewModel: TrackerViewModel())
    
    func testTrackersViewControllerDark() {
        sleep(1)
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)),
                       record: false)
    }
    
    func testTrackersViewControllerLight() {
        sleep(1)
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)),
                       record: false)
    }
}
