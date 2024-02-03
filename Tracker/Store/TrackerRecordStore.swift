import Foundation
import CoreData

protocol TrackerRecordStoreProtocol {
    func deleteOrCreateTrackerRecord(id: UUID, date: Date) -> Result<Void, Error>
    func getCountTrackerRecord(id: UUID) -> Result<Int, Error>
    func treckersRecordsResult() -> Result<Set<TrackerRecord>, Error>
    func getIsTrackerRecord(id: UUID, date: Date) throws -> Bool
    func getCountTrackerComplet() -> Int?
    func deleteTrackerRecord(id: UUID) -> Result<Void, Error>
    func deleteTrackerRecords(trackers: [Tracker]) -> Result<Void, Error>
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStore(trackerRecordStore: TrackerRecordStoreProtocol,
                            flag: Bool)
}

final class TrackerRecordStore: NSObject {
    weak var delegate: TrackerRecordStoreDelegate?
    
    private var flag: Bool = false
    private let context: NSManagedObjectContext
    
    private lazy var fetchedTrackerRecordResultController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerRecordCoreData.date, ascending: true)]
        let fetchedResultController = NSFetchedResultsController(fetchRequest: request,
                                                                 managedObjectContext: context,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        fetchedResultController.delegate = self
        try? fetchedResultController.performFetch()
        
        return fetchedResultController
    }()
    
    convenience override init() {
        let context = AppDelegate.container.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

private extension TrackerRecordStore {
    func save() -> Result<Void, Error> {
        do {
            try context.save()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func trackerRecord(from trackerRecordCoreDate: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = trackerRecordCoreDate.trackerId else {
            throw StoreErrors.TrackrerRecordStoreError.decodingErrorInvalidId
        }
        guard let date = trackerRecordCoreDate.date else {
            throw StoreErrors.TrackrerRecordStoreError.decodingErrorInvalidDate
        }
        let trackerRecord = TrackerRecord(id: id, date: date)
        
        return trackerRecord
    }
    
    func updateExistingTrackerRecord(_ trackerRecordCoreData: TrackerRecordCoreData,
                                     id: UUID,
                                     date: Date) {
        trackerRecordCoreData.trackerId = id
        trackerRecordCoreData.date = date
    }
    
    func addNewTrackerRecord(id: UUID, date: Date) -> Result<Void, Error> {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExistingTrackerRecord(trackerRecordCoreData, id: id,
                                    date: date)
        return save()
    }
    
    func deleteTrackerRecord(_ trackerRecordCoreData: TrackerRecordCoreData) -> Result<Void, Error> {
        context.delete(trackerRecordCoreData)
        return save()
    }
    
    func searchTrackerRecordForDate(id: UUID, date: Date) throws -> TrackerRecordCoreData? {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "\(TrackerRecordCoreData.self)")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(TrackerRecordCoreData.date),
                                        date as CVarArg,
                                        #keyPath(TrackerRecordCoreData.trackerId),
                                        id as CVarArg)
        let trackerRecord = try context.fetch(request)
        
        return trackerRecord.first
    }
    
    func getLisTrackersRecord(id: UUID) throws -> [TrackerRecordCoreData] {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "\(TrackerRecordCoreData.self)")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerRecordCoreData.trackerId),
                                        id as CVarArg)
        return try context.fetch(request)
    }
}

//MARK: - TrackerRecordStoreProtocol
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func treckersRecordsResult() -> Result<Set<TrackerRecord>, Error> {
        let trackerRecordsCoreData = fetchedTrackerRecordResultController.fetchedObjects
        guard let trackerRecordsCoreData
        else { return .failure(StoreErrors.TrackrerRecordStoreError.loadTrackerRecord) }
        do {
            let trackerRecord = try trackerRecordsCoreData.map ({ try self.trackerRecord(from: $0) })
            return .success(Set(trackerRecord))
        } catch {
            return .failure(error)
        }
    }
    
    func deleteTrackerRecord(id: UUID) -> Result<Void, Error> {
        do {
            let trackerRecord = try getLisTrackersRecord(id: id)
            trackerRecord.forEach { context.delete($0) }
        }
        catch {
            return .failure(error)
        }
        flag = false
        return save()
    }
    
    func deleteTrackerRecords(trackers: [Tracker]) -> Result<Void, Error> {
        do {
            try trackers.forEach {
                let trackerRecords = try getLisTrackersRecord(id: $0.id)
                trackerRecords.forEach { context.delete($0) }
            }
        } catch {
            return .failure(error)
        }
        flag = false
        return save()
    }
    
    func deleteOrCreateTrackerRecord(id: UUID, date: Date) -> Result<Void, Error> {
        flag = true
        do {
            if let trackerRecord = try searchTrackerRecordForDate(id: id,
                                                                  date: date) {
                return deleteTrackerRecord(trackerRecord)
            } else {
                return addNewTrackerRecord(id: id, date: date)
            }
        }
        catch {
            return .failure(error)
        }
    }
    
    func getCountTrackerRecord(id: UUID) -> Result<Int, Error> {
        do {
            let countTrackers = try getLisTrackersRecord(id: id).count
            return .success(countTrackers)
        } catch {
            return .failure(error)
        }
    }
    
    func getCountTrackerComplet() -> Int? {
        fetchedTrackerRecordResultController.fetchedObjects?.count
    }
    
    func getIsTrackerRecord(id: UUID, date: Date) throws -> Bool {
        do {
            let tracker = try searchTrackerRecordForDate(id: id, date: date)
            return tracker != nil
        } catch {
            throw error
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let delegate else { return }
        delegate.trackerRecordStore(trackerRecordStore: self, flag: flag)
    }
}
