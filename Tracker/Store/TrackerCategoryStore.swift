import Foundation
import CoreData

protocol TrackerCategoryStoreProtocol {
    func addCategory(_ nameCategory: String) -> Result<Void, Error>
    func getListTrackerCategoryCoreData() -> [TrackerCategoryCoreData]?
    func deleteCategory(nameCategory: String) -> Result<Void, Error>
    func updateNameCategory(newNameCategory: String, oldNameCategory: String) -> Result<Void, Error>
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func storeCategory(trackerCategoryStore: TrackerCategoryStoreProtocol)
}

final class TrackerCategoryStore: NSObject {
    weak var delegate: TrackerCategoryStoreDelegate?
    
    @UserDefaultsBacked<Bool>(key: UserDefaultKeys.isTracker.rawValue)
    private(set) var isTracker: Bool?
    
    private let context: NSManagedObjectContext
    
    private lazy var fetchedCategoryResultController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        let sortPinned = NSSortDescriptor(keyPath: \TrackerCategoryCoreData.isPinned, ascending: true)
        let sortName = NSSortDescriptor(keyPath: \TrackerCategoryCoreData.nameCategory, ascending: true)
        request.sortDescriptors = [sortPinned, sortName]
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

private extension TrackerCategoryStore {
    func save() -> Result<Void, Error> {
        do {
            try context.save()
            return .success(())
        } catch {
            return .failure(error)
        }
    }
    
    func searchTrackerCategoryCD(nameCategory: String) throws -> TrackerCategoryCoreData? {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "\(TrackerCategoryCoreData.self)")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.nameCategory),
                                        nameCategory as CVarArg)
        return try context.fetch(request).first
    }
    
    func update(trackerCategoryCD: TrackerCategoryCoreData, newNameCategory: String) -> Result<Void, Error> {
        trackerCategoryCD.nameCategory = newNameCategory
        return save()
    }
}

//MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func addCategory(_ nameCategory: String) -> Result<Void, Error> {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.nameCategory = nameCategory
        categoryCoreData.isPinned = nameCategory == Translate.textFixed ? false : true
        return save()
    }
    
    func getListTrackerCategoryCoreData() -> [TrackerCategoryCoreData]? {
        let trackCatCD = fetchedCategoryResultController.fetchedObjects
        isTracker = trackCatCD?.first { $0.trakers?.count ?? 0 > 0 } == nil
        return trackCatCD
    }
    
    func deleteCategory(nameCategory: String) -> Result<Void, Error> {
        do {
            if let category = try searchTrackerCategoryCD(nameCategory: nameCategory) {
                context.delete(category)
                return save()
            }
        } catch {
            return .failure(error)
        }
        return save()
    }
    
    func updateNameCategory(newNameCategory: String,
                            oldNameCategory: String) -> Result<Void, Error> {
        do {
            if let trackCatCD = try searchTrackerCategoryCD(nameCategory: oldNameCategory) {
                return update(trackerCategoryCD: trackCatCD, newNameCategory: newNameCategory)
            }
        } catch {
            return .failure(error)
        }
        return save()
    }

}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let delegate
        else { return }
        delegate.storeCategory(trackerCategoryStore: self)
    }
}
