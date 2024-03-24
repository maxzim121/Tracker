import Foundation
import CoreData

protocol TrackerStoreProtocol {
    func addNewTracker(_ tracker: Tracker, nameCategory: String) -> Result<Void, Error>
    func getTrackers(_ objects: [TrackerCoreData]) -> Result<[Tracker], Error>
    func updateTracker(tracker: Tracker, nameCategory: String?) -> Result<Void, Error>
    func deleteTracker(_ id: UUID) -> Result<Void, Error>
    func deleteTrackers(trackers: [Tracker]) -> Result<Void, Error>
    func addPinnedCategory(_ id: UUID, pinnedCategory: PinnCategoryCoreData) -> Result<Void, Error>
}

protocol TrackerStoreDelegate: AnyObject {
    func updateTracker(_ trackerCoreData: TrackerStoreProtocol)
}

final class TrackerStore: NSObject {
    weak var delegate: TrackerStoreDelegate?
    
    private let context: NSManagedObjectContext
    private let colorMarshalling = UIColorMarshalling()
    
    private lazy var fetchedTrackerResultController: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
        let sortName = NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        request.sortDescriptors = [sortName]
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

private extension TrackerStore {
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id else {
            assertionFailure("not found ID")
            throw StoreErrors.TrackrerStoreError.decodingErrorInvalidId
        }
        
        guard let name = trackerCoreData.name else {
            throw  StoreErrors.TrackrerStoreError.decodingErrorInvalidName
        }
        
        guard let emoji = trackerCoreData.emoji else {
            throw StoreErrors.TrackrerStoreError.decodingErrorInvalidEmoji
        }
        
        guard let color = trackerCoreData.colorHex else {
            throw StoreErrors.TrackrerStoreError.decodingErrorInvalidColor
        }
        
        guard let schedul = trackerCoreData.schedule as? [WeekDay] else {
            throw StoreErrors.TrackrerStoreError.decodingErrorInvalidSchedul
        }
        
        return Tracker(id: id,
                       name: name,
                       color: colorMarshalling.color(from: color),
                       emoji: emoji,
                       schedule: schedul)
    }
    
    func updateExistingTrackerRecord(trackerCoreData: TrackerCoreData, tracker: Tracker) {
        trackerCoreData.id = tracker.id
        trackerCoreData.colorHex = colorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.name = tracker.name
        trackerCoreData.schedule = tracker.schedule as NSObject
    }
    
    func save() -> Result<Void, Error> {
        do {
            try context.save()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func searchTracker(id: UUID) throws -> TrackerCoreData? {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "\(TrackerCoreData.self)")
        request.returnsObjectsAsFaults = false
        guard let keyPath = (\TrackerCoreData.id)._kvcKeyPathString
        else { throw StoreErrors.TrackrerStoreError.getTrackerError }
        request.predicate = NSPredicate(format: "%K == %@", keyPath, id as CVarArg)
        let trackerCD = try context.fetch(request)
        return trackerCD.first
    }
    
    func searchCategory(name: String) throws -> TrackerCategoryCoreData? {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "\(TrackerCategoryCoreData.self)")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerCategoryCoreData.nameCategory),
                                        name as CVarArg)
        return try context.fetch(request).first
    }
    
    func updateTrackerAndCategory(tracker: Tracker, nameCategory: String) -> Result<Void, Error> {
        do {
            if let categoryCD = try searchCategory(name: nameCategory) {
                do {
                    if let trackerCD = try searchTracker(id: tracker.id) {
                        trackerCD.category = categoryCD
                        updateExistingTrackerRecord(trackerCoreData: trackerCD,
                                                    tracker: tracker)
                        return save()
                    }
                } catch {
                    return .failure(error)
                }
            }
        } catch {
            return .failure(error)
        }
        return save()
    }
    
    func updateTracker(tracker: Tracker) -> Result<Void, Error> {
        do {
            if let trackerCD = try searchTracker(id: tracker.id) {
                updateExistingTrackerRecord(trackerCoreData: trackerCD,
                                            tracker: tracker)
                return save()
            }
        } catch {
            return .failure(error)
        }
        return .failure(StoreErrors.TrackrerStoreError.getTrackerError)
    }
}

extension TrackerStore: TrackerStoreProtocol {
    func addNewTracker(_ tracker: Tracker,
                       nameCategory: String) -> Result<Void, Error> {
        do {
            if let category = try searchCategory(name: nameCategory) {
                let trackerCoreData = TrackerCoreData(context: context)
                updateExistingTrackerRecord(trackerCoreData: trackerCoreData,
                                            tracker: tracker)
                category.addToTrakers(trackerCoreData)
                return save()
            }
        } catch {
            return .failure(error)
        }
        return save()
    }
    
    func updateTracker(tracker: Tracker, nameCategory: String?) -> Result<Void, Error> {
        do {
            if let nameCategory {
                return updateTrackerAndCategory(tracker: tracker, nameCategory: nameCategory)
            } else {
                return updateTracker(tracker: tracker)
            }
        }
    }
    
    func deleteTracker(_ id: UUID) -> Result<Void, Error> {
        do {
            if let trackerCoreData = try searchTracker(id: id) {
                context.delete(trackerCoreData)
                return save()
            }
        } catch {
            return .failure(error)
        }
        return save()
    }
    
    func deleteTrackers(trackers: [Tracker]) -> Result<Void, Error> {
        do { try trackers .forEach {
            if let tracker = try searchTracker(id: $0.id) {
                context.delete(tracker)
            }
        }
            return save()
        } catch {
            return .failure(error)
        }
    }
    
    func getTrackers(_ objects: [TrackerCoreData]) -> Result<[Tracker], Error> {
        let _ = fetchedTrackerResultController
        do {
            let trackers = try objects.map({ try tracker(from: $0) }).sorted { $0.name < $1.name }
            return .success(trackers)
        } catch {
            return .failure(error)
        }
    }
    
    func addPinnedCategory(_ id: UUID, pinnedCategory: PinnCategoryCoreData) -> Result<Void, Error> {
        do {
            if let trackerCD = try searchTracker(id: id) {
                pinnedCategory.addToTracker(trackerCD)
                pinnedCategory.trackerId = id
                return save()
            }
        } catch {
            return .failure(error)
        }
        return save()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let delegate else { return }
        delegate.updateTracker(self)
    }
}
