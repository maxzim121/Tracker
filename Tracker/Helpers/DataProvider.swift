import Foundation
import CoreData

protocol DataProviderDelegate: AnyObject {
    func storeCategory(_ at: DataProvider, indexPath: IndexPath)
}

protocol DataProviderProtocol {
    var trackerCategory: [TrackerCategory] { get }
    var treckersRecords: Set<TrackerRecord> { get }
    
    func addTracker(_ category: TrackerCategory, tracker: Tracker) throws
    func addNewCategory(_ nameCategori: String, tracker: Tracker) throws
    
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws
    func loadTrackerRecord(id: UUID) throws -> Int
}

final class DataProvider: NSObject {
    weak var delegate: DataProviderDelegate?
    
    private let context: NSManagedObjectContext
    
    private let trackerStore: TrackerStoreProtocol
    private let trackerCategoryStore: TrackerCategoryStoreProtocol
    private let trackerRecordStore: TrackerRecordStore
    
    private var indexPathCategory: IndexPath?
        
    init(_ delegate: DataProviderDelegate) throws {
        let context = AppDelegate.container.viewContext
        self.delegate = delegate
        self.context = context
        self.trackerStore = TrackerStore()
        self.trackerCategoryStore = TrackerCategoryStore()
        self.trackerRecordStore = TrackerRecordStore()
    }
    
    private lazy var fetchedTrackerResultController: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.id, ascending: true)
        ]
        let fetchedResultController = NSFetchedResultsController(fetchRequest: request,
                                                                 managedObjectContext: context,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
        
        return fetchedResultController
    }()
    
    private lazy var fetchedCategoryResultController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.nameCategory, ascending: true)]
        let fetchedResultController = NSFetchedResultsController(fetchRequest: request,
                                                                 managedObjectContext: context,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
        
        return fetchedResultController
    }()
    
    private lazy var fetchedTrackerRecordResultController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)]
        let fetchedResultController = NSFetchedResultsController(fetchRequest: request,
                                                                 managedObjectContext: context,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        try? fetchedResultController.performFetch()
        
        return fetchedResultController
    }()
}

//MARK: - DataProviderprotocol
extension DataProvider: DataProviderProtocol {
    var treckersRecords: Set<TrackerRecord>  {
        guard let objects = fetchedTrackerRecordResultController.fetchedObjects
        else { return [] }
        let treckersRecords = trackerRecordStore.treckersRecordsResult(trackerRecordsCoreData: objects)
        return treckersRecords
    }
    
    var trackerCategory: [TrackerCategory] {
        guard let objects = fetchedCategoryResultController.fetchedObjects
        else { return [] }
        let treckerCategory = trackersCategoryResult(trackerCategoryCoreData: objects)
        
        return treckerCategory
    }
    
    func addTracker(_ category: TrackerCategory, tracker: Tracker) throws {
        fetchedCategoryResultController.delegate = nil
        let _ = fetchedTrackerResultController.fetchedObjects
        try trackerStore.addNewTracker(tracker, category: category)
    }
    
    func addNewCategory(_ nameCategori: String, tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        try trackerStore.update(trackerCoreData, tracker: tracker)
        try trackerCategoryStore.addNewCategory(nameCategory: nameCategori, trackerCoreData: trackerCoreData)
    }
    
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        try trackerRecordStore.addNewTrackerRecord(trackerRecord)
    }
    
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        try trackerRecordStore.deleteTrackerRecord(trackerRecord)
    }
    
    func loadTrackerRecord(id: UUID) throws -> Int {
        try trackerRecordStore.loadTrackerRecord(id: id)
    }
}

extension DataProvider {
    func category(from trackerCategoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let nameCategory = trackerCategoryCoreData.nameCategory else {
            throw TrackrerCategoryStoreError.decodingErrorInvalidNameCategori
        }

        guard let arrayTrackersCoreData = trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData] else { throw NSSetError.transformationErrorInvalid }

        let arrayTrackers = try arrayTrackersCoreData.map ({ try self.trackerStore.tracker(from: $0) })

        return TrackerCategory(categoryName: nameCategory, categoryTrackers: arrayTrackers)
    }
    
    func trackersCategoryResult(trackerCategoryCoreData: [TrackerCategoryCoreData]) -> [TrackerCategory] {
        guard let treckerCategory = try? trackerCategoryCoreData.map ({ try self.category(from: $0) })
        else { return [] }
        
        return treckerCategory
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        indexPathCategory = IndexPath()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let delegate,
              let indexPathCategory
        else { return }
        delegate.storeCategory(self, indexPath: indexPathCategory)
        self.indexPathCategory = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        if case .insert = type {
            guard let indexPath = newIndexPath else { fatalError() }
            indexPathCategory = indexPath
        }
    }
}
