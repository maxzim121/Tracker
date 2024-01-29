import Foundation
import CoreData

enum TrackreRecordStoreError: Error {
    case decodingErrorInvalidId
    case decodingErrorInvalidDate
    case loadTrackerRecord(Error)
}

protocol TrackerRecordStoreProtocol {
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws
    func loadTrackerRecord(id: UUID) throws -> Int
    func treckersRecordsResult(trackerRecordsCoreData: [TrackerRecordCoreData]) throws -> Set<TrackerRecord>
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    
    convenience override init() {
        let context = AppDelegate.container.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

private extension TrackerRecordStore {
    func trackerRecord(from trackerRecordCoreDate: TrackerRecordCoreData) throws -> TrackerRecord {
        guard let id = trackerRecordCoreDate.trackerID else {
            throw TrackreRecordStoreError.decodingErrorInvalidId
        }
        guard let date = trackerRecordCoreDate.date else {
            throw TrackreRecordStoreError.decodingErrorInvalidDate
        }
        let trackerRecord = TrackerRecord(id: id, date: date)
        
        return trackerRecord
    }
    
    func updateExistingTrackerRecord(_ trackerRecordCoreData: TrackerRecordCoreData, trackerRecord: TrackerRecord) {
        trackerRecordCoreData.trackerID = trackerRecord.id
        trackerRecordCoreData.date = trackerRecord.date
    }
}

//MARK: - TrackerRecordStoreProtocol
extension TrackerRecordStore: TrackerRecordStoreProtocol {
    func treckersRecordsResult(trackerRecordsCoreData: [TrackerRecordCoreData]) -> Set<TrackerRecord> {
        guard let trackerRecord = try? trackerRecordsCoreData.map ({ try self.trackerRecord(from: $0) })
        else { return [] }

        return Set(trackerRecord)
    }
    
    func addNewTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExistingTrackerRecord(trackerRecordCoreData, trackerRecord: trackerRecord)
        try context.save()
    }
    
    func deleteTrackerRecord(_ trackerRecord: TrackerRecord) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                        #keyPath(TrackerRecordCoreData.date),
                                        trackerRecord.date as CVarArg,
                                        #keyPath(TrackerRecordCoreData.trackerID),
                                        trackerRecord.id as CVarArg)
        let trackers = try context.fetch(request)
        if let tracker = trackers.first {
            context.delete(tracker)
            try context.save()
        }
    }
    
    func loadTrackerRecord(id: UUID) throws -> Int {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.trackerID), id as CVarArg)
        let countTrackers = try context.fetch(request).count
        return countTrackers
    }
}
