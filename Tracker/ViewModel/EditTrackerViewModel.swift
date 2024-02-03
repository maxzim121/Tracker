import UIKit

protocol EditTrackerModelProtocol {
    var isSchedul: Bool { get }
    var listSettings: [ChoiceParametrs] { get }
    
    func reverseIsSchedul()
    func checkingForEmptiness() -> Bool
    func jonedSchedule(schedule: [WeekDay], stringArrayDay: String) -> String
    func setListWeekDay(listWeekDay: [WeekDay])
    func getColorRow(color: UIColor) -> Int
    func getEmojiRow(emoji: String) -> Int
    
    func setSchedule(_ vc: CreateTrackerViewController, schedule: [WeekDay])
    func setColor(_ vc: CreateTrackerViewController, color: UIColor)
    func setNameNewCategory(_ vc: CreateTrackerViewController, nameCategory: String)
    func setNameTracker(_ vc: CreateTrackerViewController, nameTracker: String)
    func setEmojiTracker(_ vc: CreateTrackerViewController, emoji: String)
    func editPinnedCategory(_ id: UUID, newPinnedCat: String) -> Result<Void, Error>
    func editTracker(vc: CreateTrackerViewController, editTracker: Tracker, nameCategory: String, isPinned: Bool)
}

//MARK: - EditTrackerViewModel
final class EditTrackerViewModel {
    var isSchedul: Bool = true
    var listSettings: [ChoiceParametrs] { isSchedul ? [.category] : [.category, .schedule] }
    
    @Observable<[WeekDay]> private(set) var schedule: [WeekDay] = []
    @Observable<UIColor?> private(set) var color: UIColor?
    @Observable<String> private(set) var nameNewCategory: String = ""
    @Observable<String> private(set) var nameTracker: String = ""
    @Observable<String> private(set) var emoji: String = ""
    private(set) var isPinned: Bool = false
    private(set) var id: UUID?
    
    private let marshalling: UIColorMarshalling
    private let pinnedCategoryStore: PinnedCategoryStoreProtocol
    
    convenience init() {
        let marshalling = UIColorMarshalling()
        let pinnedCategoryStore = PinnedCategoryStore()
        self.init(marshalling: marshalling,
                  pinnedCategoryStore: pinnedCategoryStore)
    }
    
    init(marshalling: UIColorMarshalling,
         pinnedCategoryStore: PinnedCategoryStoreProtocol) {
        self.marshalling = marshalling
        self.pinnedCategoryStore = pinnedCategoryStore
    }
}

//MARK: - EditTrackerViewModel
extension EditTrackerViewModel: EditTrackerModelProtocol {
    func checkingForEmptiness() -> Bool {
        var flag: Bool
        if isSchedul {
            flag = !nameTracker.isEmpty &&
            color != nil &&
            !emoji.isEmpty &&
            !nameNewCategory.isEmpty ? true : false
            
            return flag
        }
        flag = !schedule.isEmpty &&
        !nameTracker.isEmpty &&
        color != nil &&
        !emoji.isEmpty &&
        !nameNewCategory.isEmpty ? true : false
        return flag
    }
    
    func reverseIsSchedul() {
        isSchedul = isSchedul ? !isSchedul : isSchedul
    }
    
    func jonedSchedule(schedule: [WeekDay],
                       stringArrayDay: String) -> String {
        var stringListDay: String
        if schedule.count == DataSource.regular.count {
            stringListDay = stringArrayDay
            return stringListDay
        }
        let listDay = schedule.map { $0.briefWordDay }
        stringListDay = listDay.joined(separator: ",")
        
        return stringListDay
    }
    
    func setListWeekDay(listWeekDay: [WeekDay]) {
        schedule = listWeekDay
    }
    
    func getColorRow(color: UIColor) -> Int {
        var colorRow: Int = 0
        for (index, value) in DataSource.colors.enumerated() {
            let colorMarshalling = marshalling.color(from: marshalling.hexString(from: value))
            if colorMarshalling == color {
                colorRow = index
            }
        }
        return colorRow
    }
    
    func getEmojiRow(emoji: String) -> Int {
        var emojiRow: Int = 0
        for (index, value) in DataSource.emojies.enumerated() {
            if value == emoji {
                emojiRow = index
            }
        }
        return emojiRow
    }
    
    func setSchedule(_ vc: CreateTrackerViewController, schedule: [WeekDay]) {
        self.schedule = schedule
    }
    
    func setColor(_ vc: CreateTrackerViewController, color: UIColor) {
        self.color = color
    }
    
    func setNameNewCategory(_ vc: CreateTrackerViewController, nameCategory: String) {
        self.nameNewCategory = nameCategory
    }
    
    func setNameTracker(_ vc: CreateTrackerViewController, nameTracker: String) {
        self.nameTracker = nameTracker
    }
    
    func setEmojiTracker(_ vc: CreateTrackerViewController, emoji: String) {
        self.emoji = emoji
    }
    
    func editPinnedCategory(_ id: UUID, newPinnedCat: String) -> Result<Void, Error>  {
        pinnedCategoryStore.editPinnedCategory(id, newPinnedCat: newPinnedCat)
    }
    
    func editTracker(vc: CreateTrackerViewController,
                     editTracker: Tracker,
                     nameCategory: String,
                     isPinned: Bool) {
        schedule = editTracker.schedule
        color = editTracker.color
        nameNewCategory = nameCategory
        nameTracker = editTracker.name
        emoji = editTracker.emoji
        id = editTracker.id
        self.isPinned = isPinned
    }
}
