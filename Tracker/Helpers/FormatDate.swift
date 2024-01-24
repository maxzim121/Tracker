//
//  FormatDate.swift
//  Tracker
//
//  Created by Maksim Zimens on 21.01.2024.
//

import Foundation

final class FormatDate {
    static let shared = FormatDate()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "e"

        return dateFormatter
    }()
    
    func greateWeekDayInt(date: Date) -> Int {
        let weekDayString = dateFormatter.string(from: date)
        let deyWeek = NSString(string: weekDayString).intValue - 1
        return Int(deyWeek)
    }
}
