//
//  RecordManager.swift
//  Tracker
//
//  Created by Maksim Zimens on 21.01.2024.
//

import Foundation

protocol RecordManagerProtocol {
    func getCategories() -> [TrackerCategory]
    func updateCategories(newCategories: [TrackerCategory])
}

final class RecordManager: RecordManagerProtocol {
    
    
    
    static let shared = RecordManager()
    
    private var categories: [TrackerCategory] = []
    
    func getCategories() -> [TrackerCategory] {
        return categories
    }
    
    func updateCategories(newCategories: [TrackerCategory]) {
        categories = newCategories
    }
}
