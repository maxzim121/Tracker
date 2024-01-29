import Foundation
import UIKit

final class ButtonCellView: UITableViewCell {
    
    var label = UILabel()
    var secondaryLabel = UILabel()
    let stack = UIStackView()
    let arrowImage = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "Cell")
        contentView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        contentView.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        configureLabelsStack()
        configureArrowImage()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureArrowImage() {
        contentView.addSubview(arrowImage)
        arrowImage.translatesAutoresizingMaskIntoConstraints = false
        arrowImage.image = UIImage(named: "Chevron")
        NSLayoutConstraint.activate([
            arrowImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            arrowImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImage.heightAnchor.constraint(equalToConstant: 24),
            arrowImage.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func configureLabelsStack() {
        contentView.addSubview(stack)
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        [label, secondaryLabel].forEach {
            $0.backgroundColor = .clear
            $0.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview($0)
        }
        label.font = .systemFont(ofSize: 17)
        label.textColor = .black
        secondaryLabel.font = .systemFont(ofSize: 17)
        secondaryLabel.textColor = .gray
        secondaryLabel.isHidden = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
    }
    
    func jonedSchedule(schedule: [WeekDay]) -> String {
        var stringListDay: String
        if schedule.count == 7 {
            stringListDay = "Каждый день"
            return stringListDay
        }
        return schedule
                   .map { $0.briefWordDay }
                   .joined(separator: ",")    }
    
    
    
}
