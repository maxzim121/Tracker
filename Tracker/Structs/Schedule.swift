import Foundation

enum WeekDay: Int, Codable {
    case monday = 0
    case tuesday = 1
    case wednesday = 2
    case thursday = 3
    case friday = 4
    case saturday = 5
    case sunday = 6
    
    var day: String {
        var day: String
        switch self {
        case .monday:
            day = "Понедельник"
        case .tuesday:
            day = "Вторник"
        case .wednesday:
            day = "Среда"
        case .thursday:
            day = "Четверг"
        case .friday:
            day = "Пятница"
        case .saturday:
            day = "Суббота"
        case .sunday:
            day = "Воскресенье"
        }
        return day
    }
    
    var briefWordDay: String {
        var briefWordDay: String
        switch self {
        case .monday:
            briefWordDay = "Пн"
        case .tuesday:
            briefWordDay = "Вт"
        case .wednesday:
            briefWordDay = "Ср"
        case .thursday:
            briefWordDay = "Чт"
        case .friday:
            briefWordDay = "Пт"
        case .saturday:
            briefWordDay = "Сб"
        case .sunday:
            briefWordDay = "Вс"
        }
        return briefWordDay
    }
}
