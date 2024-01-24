//
//  Date.swift
//  Tracker
//
//  Created by Maksim Zimens on 21.01.2024.
//

import Foundation

extension Date {
    var ignoringTime: Date? {
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: self)
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
}
