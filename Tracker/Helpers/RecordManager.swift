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
    
    private var categories: [TrackerCategory] = [TrackerCategory(categoryName: "Категория", categoryTrackers: [
        Tracker(name: "Лес", id: UUID(), color: .blue, emoji: "🏝️", schedule: [  .wednesday, .monday, .sunday]),
        Tracker(name: "Жыве", id: UUID(), color: .green, emoji: "🙌", schedule: [  .wednesday]),
        Tracker(name: "Вечна", id: UUID(), color: .black, emoji: "😡", schedule: [ .monday, .wednesday,  .sunday, .saturday])
    ])]
    
    func getCategories() -> [TrackerCategory] {
        return categories
    }
    
    func updateCategories(newCategories: [TrackerCategory]) {
        categories = newCategories
    }
}
