//
//  CategoryVIewModel.swift
//  Tracker
//
//  Created by Maksim Zimens on 30.01.2024.
//

import Foundation

final class CategoryViewModel {
    @Observable<[TrackerCategory]> private(set) var category = []
    @UserDefaultsBacked<String?>(key: "select_name_category") var selectNameCategory
    @Observable<IndexPath> private(set) var categoryIndexPath = IndexPath()
    
    private var model: DataProvider?
    
    init() {
        model = DataProvider(delegate: self)
        category = model?.trackerCategory ?? []
    }
}

extension CategoryViewModel {
    func addCategory(nameCategory: String) throws {
        guard let model else { return }
        try model.addCategory(nameCategory: nameCategory)
    }
    
    func selectСategory(at index: Int) {
        selectNameCategory = category[index].categoryName
    }
    
    func createNameCategory(at index: Int) -> String {
        category[index].categoryName
    }
    
    func isCategorySelected(at index: Int) -> Bool {
        category[index].categoryName != selectNameCategory
    }
}

//MARK: - DataProviderDelegate
extension CategoryViewModel: DataProviderDelegate {
    func storeCategory(dataProvider: DataProvider, indexPath: IndexPath) {
        category = dataProvider.trackerCategory
        categoryIndexPath = indexPath
    }
}
