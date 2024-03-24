enum Header: String {
    case color
    case emoji = "Emoji"
    
    var name: String {
        var name: String
        switch self {
        case .color:
            name = Translate.colorHeader
        case .emoji:
            name = self.rawValue
        }
        return name
    }
}

