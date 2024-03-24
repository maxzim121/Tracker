import Foundation

protocol SheduleViewModelProtocol {
    var weekDay: [WeekDay] { get }
    var listWeekDay: [WeekDay] { get }
    func setListWeekDay(listWeekDay: [WeekDay])
}

final class SheduleViewModel {
    let weekDay: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    private(set) var listWeekDay: [WeekDay] = []
}

extension SheduleViewModel: SheduleViewModelProtocol {
    func setListWeekDay(listWeekDay: [WeekDay]) {
        self.listWeekDay = listWeekDay
    }
}
