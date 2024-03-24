import UIKit

enum DataSource {
    static let emojies: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
                                    "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    
    static let colors: [UIColor] = [.colorSelection1, .colorSelection2, .colorSelection3,.colorSelection4,
                                    .colorSelection5, .colorSelection6, .colorSelection7, .colorSelection8,
                                    .colorSelection9, .colorSelection10, .colorSelection11, .colorSelection12,
                                    .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16,
                                    .colorSelection17, .colorSelection18]
    
    static let dataSection: [Header] = [.emoji, .color]
    
    static let regular: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
}
