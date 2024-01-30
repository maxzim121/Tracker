import Foundation
import CoreData
import UIKit

enum TrackrerCategoryStoreError: Error {
    case decodingErrorInvalidNameCategori
}

enum NSSetError: Error {
    case transformationErrorInvalid
}

protocol TrackerCategoryStoreProtocol {
    func addNewCategory(nameCategory: String, trackerCoreData: TrackerCoreData) throws
    func addCategory(_ nameCategory: String) throws
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    
    private var indexPathCategory: IndexPath?

    convenience override init() {
        let context = AppDelegate.container.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

//MARK: - TrackerCategoryStoreProtocol
extension TrackerCategoryStore: TrackerCategoryStoreProtocol {
    func addNewCategory(nameCategory: String, trackerCoreData: TrackerCoreData) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.nameCategory = nameCategory
        categoryCoreData.addToTrackers(trackerCoreData)
        try context.save()
    }
    
    func addCategory(_ nameCategory: String) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.nameCategory = nameCategory
        try context.save()
    }

    
}
