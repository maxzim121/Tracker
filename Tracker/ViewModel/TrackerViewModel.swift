//
//  TrackerViewModel.swift
//  Tracker
//
//  Created by Maksim Zimens on 03.02.2024.
//

import Foundation

//MARK: - TrackerViewModelProtocol
protocol TrackerViewModelProtocol {
    var category: Result<[TrackerCategory], Error> { get }
    var visibleCategory: Result<[TrackerCategory], Error> { get }
    func getCategory() -> Result<[TrackerCategory], Error>
    func addCategory(nameCategory: String) -> Result<Void, Error>
    
    func getCountTrackerCompleted(id: UUID) -> Result<Int, Error>
    func deleteTrackersRecord(id: UUID) -> Result<Void, Error>
    
    func addNewTracker(_ tracker: Tracker, nameCategory: String) -> Result<Void, Error>
    func updateTracker(tracker: Tracker, nameCategory: String?) -> Result<Void, Error>
    func deleteTracker(id: UUID) -> Result<Void, Error>
    
    func getShowListTrackersForDay(date: Date)
    func getShowListTrackerSearchForName(_ searchCategory: [TrackerCategory])
    func filterListTrackersName(word: String) -> Result<[TrackerCategory], Error>
    
    func addPinnedCategory(id: UUID, nameCategory: String)  -> Result<Void, Error>
    func editPinnedCategory(_ id: UUID, newPinnedCat: String) -> Result<Void, Error>
    func getPinnedCategory(_ id: UUID) -> Result<String?, Error>
    func deleteAndGetPinnedCategory(id: UUID) -> Result<String?, Error>
    
    func allTrackersByDate(date: Date)
    func getNotCompleted(date: Date, flag: Bool)
    func getCompleted(date: Date, flag: Bool)
    
    func setFilterState(state: FiltersState)
    func getFilterState() -> FiltersState
    
    func getIsCategoryForDay() -> Bool?
}

//MARK: - TrackerViewModel
final class TrackerViewModel {
    @Observable<Result<[TrackerCategory], Error>>
    private(set) var category: Result<[TrackerCategory], Error>
    
    @Observable<Result<[TrackerCategory], Error>>
    private(set) var visibleCategory: Result<[TrackerCategory], Error>
    
    @Observable<Bool?> private(set) var isfilterListTrackersWeekDay: Bool?
    @Observable<IndexPath> private(set) var indexPath: IndexPath
    @Observable<FiltersState>private(set) var filterState: FiltersState
    
    @UserDefaultsBacked<String>(key: UserDefaultKeys.selectNameCategory.rawValue)
    private var selectNameCategory: String?
    
    @UserDefaultsBacked<String>(key: UserDefaultKeys.selectFilter.rawValue)
    private var selectFilter: String?
    
    @UserDefaultsBacked<Bool>(key: UserDefaultKeys.isTracker.rawValue)
    private(set) var isTracker: Bool?
    
    private(set) var completedTrackers: Result<Set<TrackerRecord>, Error>
    
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let trackerRecordStore: TrackerRecordStoreProtocol
    private let trackerStore: TrackerStoreProtocol
    private let pinnedCategoryStore: PinnedCategoryStoreProtocol
    
    convenience init() {
        let trackerCategoryStore = TrackerCategoryStore()
        let trackerRecordStore = TrackerRecordStore()
        let trackerStore = TrackerStore()
        let pinnedCategoryStore = PinnedCategoryStore()
        self.init(trackerCategoryStore: trackerCategoryStore,
                  trackerRecordStore: trackerRecordStore,
                  trackerStore: trackerStore,
                  pinnedCategoryStore: pinnedCategoryStore,
                  category: .success([]),
                  completedTrackers: .success(Set()),
                  visibleCategory: .success([]),
                  indexPath: IndexPath(),
                  filterState: .allTrackers)
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self
        trackerStore.delegate = self
        category = getCategory()
        completedTrackers = treckersRecordsResult()
        guard let state = selectFilter else {
            filterState = .allTrackers
            return
        }
        filterState = FiltersState(rawValue: state) ?? .allTrackers
    }
    
    init(trackerCategoryStore: TrackerCategoryStoreProtocol,
         trackerRecordStore: TrackerRecordStoreProtocol,
         trackerStore: TrackerStoreProtocol,
         pinnedCategoryStore: PinnedCategoryStoreProtocol,
         category: Result<[TrackerCategory], Error>,
         completedTrackers: Result<Set<TrackerRecord>, Error>,
         visibleCategory: Result<[TrackerCategory], Error>,
         indexPath: IndexPath, filterState: FiltersState) {
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        self.trackerStore = trackerStore
        self.pinnedCategoryStore = pinnedCategoryStore
        self.category = category
        self.completedTrackers = completedTrackers
        self.visibleCategory = visibleCategory
        self.indexPath = indexPath
        self.filterState = filterState
    }
}
//MARK: - Extension
private extension TrackerViewModel {
    func category(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let nameCategory = trackerCategoryCoreData.nameCategory else {
            throw StoreErrors.TrackrerCategoryStoreError.decodingErrorInvalidNameCategory
        }
        guard let arrayTrackersCoreData = trackerCategoryCoreData.trakers?.allObjects
                as? [TrackerCoreData]
        else { throw StoreErrors.NSSetError.transformationErrorInvalid }
        let result = trackerStore.getTrackers(arrayTrackersCoreData)
        switch result {
        case .success(let trackers):
            return TrackerCategory(nameCategory: nameCategory,
                                   arrayTrackers: trackers,
                                   isPinned: trackerCategoryCoreData.isPinned)
        case .failure(let error):
            throw error
        }
    }
    
    func setVisibleCategory(date: Date, flag: Bool) {
        switch category {
        case .success(let category):
            var listCategories: [TrackerCategory] = []
            let filterCategory = filterListTrackersWeekDay(trackerCategory: category,
                                                           date: date)
            filterCategory.forEach {
                do {
                    let cat = try trackerCompletedOrNotByCategory(category: $0,
                                                                  date: date.ignoringTime,
                                                                  flag: flag,
                                                                  filter: trackerRecordStore.getIsTrackerRecord(id:date:))
                    if !cat.arrayTrackers.isEmpty {
                        listCategories.append(cat)
                    }
                } catch {
                    visibleCategory = .failure(error)
                }
            }
            visibleCategory = .success(listCategories)
        case .failure(let error):
            visibleCategory = .failure(error)
        }
    }
    
    func filterListTrackersWeekDay(trackerCategory: [TrackerCategory],
                                   date: Date) -> [TrackerCategory] {
        let calendar = Calendar.current
        let filter = calendar.component(.weekday, from: date)
        
        let listCategories: [TrackerCategory] = trackerCategory.compactMap { cat in
            let trackers = cat.arrayTrackers.filter { tracker in
                tracker.schedule.contains { weekDay in
                    weekDay.rawValue + 1 == filter
                }
            }
            
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(nameCategory: cat.nameCategory,
                                   arrayTrackers: trackers,
                                   isPinned: cat.isPinned)
        }
        
        isfilterListTrackersWeekDay = !listCategories.isEmpty
        return listCategories
    }
    
    func filterListTrackersCompleted(date: Date, flag: Bool) {
        setVisibleCategory(date: date, flag: flag)
    }
    
    func filterListTrackersNotCompleted(date: Date, flag: Bool) {
        setVisibleCategory(date: date, flag: flag)
    }
    
    func deleteOrCreateTrackerRecord(id: UUID, date: Date) -> Result<Void, Error> {
        trackerRecordStore.deleteOrCreateTrackerRecord(id: id, date: date.ignoringTime)
    }
    
    func trackerCompletedOrNotByCategory(category: TrackerCategory,
                                         date: Date,
                                         flag: Bool,
                                         filter: (UUID, Date) throws -> Bool) throws -> TrackerCategory {
        let trackers = category.arrayTrackers
        do {
            let trackers = try trackers.filter { try flag == filter($0.id, date) }
            let cat = TrackerCategory(nameCategory: category.nameCategory,
                                      arrayTrackers: trackers,
                                      isPinned: category.isPinned)
            return cat
        } catch {
            throw error
        }
    }
}

//MARK: - TrackerViewModelProtocol
extension TrackerViewModel: TrackerViewModelProtocol
{
    func deleteTracker(id: UUID) -> Result<Void, Error> {
        trackerStore.deleteTracker(id)
    }
    
    func deleteTrackersRecord(id: UUID) -> Result<Void, Error> {
        trackerRecordStore.deleteTrackerRecord(id: id)
    }
    
    func addCategory(nameCategory: String) -> Result<Void, Error> {
        trackerCategoryStore.addCategory(nameCategory)
    }
    
    func getCategory() -> Result<[TrackerCategory], Error> {
        let trackerCategoryCoreData = trackerCategoryStore.getListTrackerCategoryCoreData()
        guard let trackerCategoryCoreData
        else { return .failure(StoreErrors.TrackrerStoreError.getTrackerError) }
        do {
            let listCategory = try trackerCategoryCoreData.map ({ try category(from: $0) })
            return .success(listCategory)
        } catch {
            return .failure(error)
        }
    }
    
    func treckersRecordsResult() -> Result<Set<TrackerRecord>, Error> {
        trackerRecordStore.treckersRecordsResult()
    }
    
    func loadTrackerRecord(id: UUID) -> Result<Int, Error> {
        trackerRecordStore.getCountTrackerRecord(id: id)
    }
    
    func addNewTracker(_ tracker: Tracker,
                       nameCategory: String) -> Result<Void, Error> {
        let trackerCoreData = trackerStore.addNewTracker(tracker,
                                                         nameCategory: nameCategory)
        return trackerCoreData
    }
    
    func updateTracker(tracker: Tracker, nameCategory: String?) -> Result<Void, Error> {
        trackerStore.updateTracker(tracker: tracker, nameCategory: nameCategory)
    }
    
    func getShowListTrackersForDay(date: Date) {
        switch category {
        case .success(let trackerCategory):
            let filterList = filterListTrackersWeekDay(trackerCategory: trackerCategory,
                                                       date: date)
            visibleCategory = .success(filterList)
        case .failure(let error):
            visibleCategory = .failure(error)
        }
    }
    
    func filterListTrackersName(word: String) -> Result<[TrackerCategory], Error> {
        var listCategories: [TrackerCategory] = []
        switch category {
        case .success(let cat):
            cat.forEach { category in
                let trackerList = category.arrayTrackers.filter { $0.name.lowercased().hasPrefix(word.lowercased()) }
                if !trackerList.isEmpty {
                    listCategories.append(TrackerCategory(nameCategory: category.nameCategory,
                                                          arrayTrackers: trackerList,
                                                          isPinned: category.isPinned))
                }
            }
            return .success(listCategories)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func updateCompletedTrackers(tracker: Tracker, date: Date) -> Result<Void, Error> {
        return deleteOrCreateTrackerRecord(id: tracker.id, date: date)
    }
    
    func getShowListTrackerSearchForName(_ searchCategory: [TrackerCategory]) {
        visibleCategory = .success(searchCategory)
    }
    
    func getIsComplited(tracker: Tracker, date: Date) -> Result<Bool, Error> {
        switch completedTrackers {
        case .success(let compTrack):
            return .success(compTrack.contains (where: { $0.id == tracker.id &&
                Calendar.current.isDate(date,
                                        equalTo: $0.date,
                                        toGranularity: .day)}))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func setIndexPath(_ indexPath: IndexPath) {
        self.indexPath = indexPath
    }
    
    func addPinnedCategory(id: UUID, nameCategory: String)  -> Result<Void, Error> {
        let pinnCategoryCoreData = pinnedCategoryStore.addPinnedCategory(nameCategory)
        switch pinnCategoryCoreData {
        case .success(let pinnCategoryCoreData):
            return trackerStore.addPinnedCategory(id,
                                                  pinnedCategory: pinnCategoryCoreData)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func editPinnedCategory(_ id: UUID, newPinnedCat: String) -> Result<Void, Error> {
        pinnedCategoryStore.editPinnedCategory(id, newPinnedCat: newPinnedCat)
    }
    
    func getPinnedCategory(_ id: UUID) -> Result<String?, Error> {
        pinnedCategoryStore.getPinnedCategory(id)
    }
    
    func deleteAndGetPinnedCategory(id: UUID) -> Result<String?, Error> {
        pinnedCategoryStore.deleteAndGetPinnedCategory(id)
    }
    
    func allTrackersByDate(date: Date) {
        getShowListTrackersForDay(date: date)
    }
    
    func getNotCompleted(date: Date, flag: Bool) {
        filterListTrackersNotCompleted(date: date, flag: flag)
    }
    
    func getCompleted(date: Date, flag: Bool) {
        filterListTrackersCompleted(date: date, flag: flag)
    }
    
    func setFilterState(state: FiltersState) {
        filterState = state
    }
    
    func getFilterState() -> FiltersState {
        filterState
    }
    
    func getSelectFilter() -> String? {
        selectFilter
    }
    
    func getCountTrackerCompleted(id: UUID) -> Result<Int, Error> {
        trackerRecordStore.getCountTrackerRecord(id: id)
    }
    
    func getIsCategoryForDay() -> Bool? {
        isfilterListTrackersWeekDay
    }
}

//MARK: - TrackerCategoryStoreDelegate
extension TrackerViewModel: TrackerCategoryStoreDelegate {
    func storeCategory(trackerCategoryStore: TrackerCategoryStoreProtocol) {
        category = getCategory()
    }
}

//MARK: - TrackerRecordStoreDelegate
extension TrackerViewModel: TrackerRecordStoreDelegate {
    func trackerRecordStore(trackerRecordStore: TrackerRecordStoreProtocol,
                            flag: Bool) {
        completedTrackers = trackerRecordStore.treckersRecordsResult()
        if flag {
            self.indexPath = indexPath
        }
    }
}

//MARK: - TrackerStoreDelegate
extension TrackerViewModel: TrackerStoreDelegate {
    func updateTracker(_ trackerCoreData: TrackerStoreProtocol) {
        category = getCategory()
    }
}
