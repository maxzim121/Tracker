import Foundation

protocol StatisticsViewModelProtocol {
    func getCountTrackerComplet() -> Int?
    func getIsTracker() -> Bool?
}

final class StatisticsViewModel {
    @Observable<Int?> private(set) var countTrackerComplet: Int?
    
    @UserDefaultsBacked<Bool>(key: UserDefaultKeys.isTracker.rawValue)
    private(set) var isTracker: Bool?
    
    let trackerRecordStore: TrackerRecordStoreProtocol
    
    convenience init() {
        let trackerRecordStore = TrackerRecordStore()
        self.init(trackerRecordStore: trackerRecordStore)
        countTrackerComplet = getCountTrackerComplet()
        trackerRecordStore.delegate = self
    }
    
    init(trackerRecordStore: TrackerRecordStoreProtocol) {
        self.trackerRecordStore = trackerRecordStore
    }
}

extension StatisticsViewModel: StatisticsViewModelProtocol {
    func getCountTrackerComplet() -> Int? {
        trackerRecordStore.getCountTrackerComplet()
    }
    
    func getIsTracker() -> Bool? {
        isTracker
    }
}

extension StatisticsViewModel: TrackerRecordStoreDelegate {
    func trackerRecordStore(trackerRecordStore: TrackerRecordStoreProtocol, flag: Bool) {
        countTrackerComplet = getCountTrackerComplet()
    }
}
