//
//  Tracker.swift
//  Tracker
//
//  Created by Maksim Zimens on 28.10.2023.
//

import UIKit
import Foundation

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
    
    init(id: UUID = UUID(),
         name: String,
         color: UIColor,
         emoji: String,
         schedule: [WeekDay]) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}

