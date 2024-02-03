//
//  NameEvent.swift
//  Tracker
//
//  Created by Maksim Zimens on 03.02.2024.
//

enum NameEvent {
    case habit
    case irregularEvent
    
    var name: String {
        var name: String
        switch self {
        case .habit:
            name = Translate.nameHabit
        case .irregularEvent:
            name = Translate.nameIrregularEvent
        }
        return name
    }
}
