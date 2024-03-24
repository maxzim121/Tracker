import Foundation

//MARK: - CategoryViewModelProtocol
protocol CategoryViewModelProtocol {
    func isCategorySelected(at index: Int) -> Result<Bool, Error>
    func getCategory() -> Result<[TrackerCategory], Error>
    func сategoryExcludingFixed() -> Result<[TrackerCategory], Error>
    func addCategory(nameCategory: String) -> Result<Void, Error>
    func createNameCategory(at index: Int) -> Result<String, Error>
    func updateNameCategory(newNameCategory: String, oldNameCaetegory: String) -> Result<Void, Error>
    func deleteCategory(nameCategory: String) -> Result<Void, Error>
    func deleteTrackers(trackers: [Tracker]) -> Result<Void, Error>
    func deleteTrackerRecords(trackers: [Tracker]) -> Result<Void, Error>
    func selectСategory(at index: Int) -> Result<Void, Error>
    func deleteSelectCategory()
}

//MARK: - ViewModel
final class CategoryViewModel {
    @Observable<Result<[TrackerCategory], Error>>
    private(set) var category: Result<[TrackerCategory], Error>
    
    @UserDefaultsBacked<String>(key: UserDefaultKeys.selectNameCategory.rawValue)
    private(set) var selectNameCategory: String?
    
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let trackerStore: TrackerStoreProtocol
    private let trackerRecordStore: TrackerRecordStoreProtocol
    
    convenience init() {
        let trackerCategoryStore = TrackerCategoryStore()
        let trackerStore = TrackerStore()
        let trackerRecordStore = TrackerRecordStore()
        self.init(trackerCategoryStore: trackerCategoryStore,
                  trackerStore: trackerStore,
                  trackerRecordStore: trackerRecordStore,
                  category: .success([])
        )
        trackerCategoryStore.delegate = self
        trackerStore.delegate = self
        category = getCategory()
    }
    
    init(trackerCategoryStore: TrackerCategoryStoreProtocol,
         trackerStore: TrackerStoreProtocol,
         trackerRecordStore: TrackerRecordStoreProtocol,
         category: Result<[TrackerCategory], Error>) {
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
        self.category = category
    }
}
//MARK: - Extension
private extension CategoryViewModel {
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
}

//MARK: - TrackerViewModelProtocol
extension CategoryViewModel: CategoryViewModelProtocol {
    func addCategory(nameCategory: String) -> Result<Void, Error> {
        trackerCategoryStore.addCategory(nameCategory)
    }
    
    func updateNameCategory(newNameCategory: String,
                            oldNameCaetegory: String) -> Result<Void, Error> {
        trackerCategoryStore.updateNameCategory(newNameCategory: newNameCategory,
                                                oldNameCategory: oldNameCaetegory)
    }
    
    func isCategorySelected(at index: Int) -> Result<Bool, Error> {
        switch сategoryExcludingFixed() {
        case .success(let category):
            return .success(category[index].nameCategory != selectNameCategory)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getCategory() -> Result<[TrackerCategory], Error> {
        let trackerCategoryCoreData = trackerCategoryStore.getListTrackerCategoryCoreData()
        guard let trackerCategoryCoreData else
        { return .failure(StoreErrors.TrackrerStoreError.getTrackerError) }
        do {
            let listCategory = try trackerCategoryCoreData.map { try category(from: $0) }
            return .success(listCategory)
        } catch {
            return .failure(error)
        }
    }
    
    func сategoryExcludingFixed() -> Result<[TrackerCategory], Error> {
        switch category {
        case .success(let category):
            let filterCat = category.filter {
                $0.nameCategory != Fixed.fixedRu.rawValue &&
                $0.nameCategory != Fixed.fixedEng.rawValue
            }
            return .success(filterCat)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func createNameCategory(at index: Int) -> Result<String, Error> {
        switch сategoryExcludingFixed() {
        case .success(let category):
            let name = category[index].nameCategory
            return .success(name)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func deleteCategory(nameCategory: String) -> Result<Void, Error> {
        trackerCategoryStore.deleteCategory(nameCategory: nameCategory)
    }
    
    func deleteTrackers(trackers: [Tracker]) -> Result<Void, Error> {
        trackerStore.deleteTrackers(trackers: trackers)
    }
    
    func deleteTrackerRecords(trackers: [Tracker]) -> Result<Void, Error> {
        trackerRecordStore.deleteTrackerRecords(trackers: trackers)
    }
    
    func selectСategory(at index: Int) -> Result<Void, Error> {
        switch сategoryExcludingFixed() {
        case .success(let category):
            print(category[index].nameCategory)
            selectNameCategory = category[index].nameCategory
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func deleteSelectCategory() {
        selectNameCategory = nil
    }
}

//MARK: - TrackerCategoryStoreDelegate
extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func storeCategory(trackerCategoryStore: TrackerCategoryStoreProtocol) {
        category = getCategory()
    }
}

//MARK: - TrackerStoreDelegate
extension CategoryViewModel: TrackerStoreDelegate {
    func updateTracker(_ trackerCoreData: TrackerStoreProtocol) {
        category = getCategory()
    }
}
