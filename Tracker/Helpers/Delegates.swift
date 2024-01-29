import Foundation
import UIKit

protocol SwitherDelegate: AnyObject {
    func switcherRecievedDay(cell: UITableViewCell, flag: Bool)
}

protocol ScheduleDelegate: AnyObject {
    func scheduleRecieved(schedule: [WeekDay])
}

protocol NewTrackersCategoryDelegate: AnyObject {
    func trackersCreated(trackers: [TrackerCategory])
}

protocol ReloadDataDelegate: AnyObject {
    func reloadData(tracker: Tracker, categoryName: String)
}

protocol TrackerCreationDelegate: AnyObject {
    func sendTracker(tracker: Tracker, categoryName: String)
}

protocol TrackersCollectionViewCellDelegate: AnyObject {
    func didTrackerCompleted(_ cell: UICollectionViewCell)
}
