//
//  ChoiceParametrs.swift
//  Tracker
//
//  Created by Maksim Zimens on 03.02.2024.
//

enum ChoiceParametrs: String {
    case category
    case schedule
    
    var name: String {
        var name: String
        switch self {
        case .category:
            name = Translate.category
        case .schedule:
            name = Translate.schedule
        }
        return name
    }
}
