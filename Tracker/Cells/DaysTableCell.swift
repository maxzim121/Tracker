import UIKit

//MARK: - WeekDayTableViewCellDelegate
protocol WeekDayTableViewCellDelegate: AnyObject {
    func addDayInListkDay(cell: UITableViewCell, flag: Bool)
}

//MARK: -
final class WeekDayTableViewCell: UITableViewCell {
    private static let dayLableFont = UIFont.systemFont(ofSize: 17,
                                                        weight: .regular)
    
    weak var delegate: WeekDayTableViewCellDelegate?
    
    private lazy var dayLable: UILabel = {
        let dayLable = UILabel()
        dayLable.font = WeekDayTableViewCell.dayLableFont
        
        return dayLable
    }()
    
    private lazy var choiceDaySwitch: UISwitch = {
        let choiceDaySwitch = UISwitch()
        choiceDaySwitch.onTintColor = .blueDay
        choiceDaySwitch.addTarget(self,
                                  action: #selector(switching),
                                  for: .touchUpInside)
        
        return choiceDaySwitch
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .backgroundDay
        layer.masksToBounds = true
        contentView.backgroundColor = .clear
        setupElement()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WeekDayTableViewCell {
    //MARK: - Обработка событий
    @objc
    private func switching(_ sender: UISwitch) {
        guard let delegate else { return }
        delegate.addDayInListkDay(cell: self,
                                  flag: choiceDaySwitch.isOn)
    }
    
    //MARK: - Configuration
    func setupCornerRadius(cornerRadius: CGFloat,
                           maskedCorners: CACornerMask) {
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = maskedCorners
    }
    
    func config(nameDay: WeekDay) {
        dayLable.text = nameDay.day
    }
    
    //MARK: - SetupUI
    private func setupElement() {
        [dayLable, choiceDaySwitch].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
            $0.backgroundColor = .clear
        }
        
        NSLayoutConstraint.activate([
            dayLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                              constant: 12),
            dayLable.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            
            choiceDaySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                      constant: -12),
            choiceDaySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
