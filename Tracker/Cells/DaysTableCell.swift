//
//  DaysTableCell.swift
//  Tracker
//
//  Created by Maksim Zimens on 30.11.2023.
//

import Foundation
import UIKit

final class DaysTableCell: UITableViewCell {
    
    weak var delegate: SwitherDelegate?
    
    var privichkaView = PrivichkaViewController()
    
    var dayLabel = UILabel()
    var switcher = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "DaysCell")
        contentView.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        contentView.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        configureDayLabel()
        configureSwitcher()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureDayLabel() {
        contentView.addSubview(dayLabel)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.font = .systemFont(ofSize: 17, weight: .regular)
        dayLabel.textColor = .black
        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
    
    private func configureSwitcher() {
        contentView.addSubview(switcher)
        switcher.onTintColor = UIColor(red: 0.22, green: 0.45, blue: 0.91, alpha: 1)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        switcher.addTarget(self, action: #selector(swithing), for: .touchUpInside)
        NSLayoutConstraint.activate([
            switcher.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func swithing(_ sender: UISwitch) {
        
        guard let delegate else { return }
        delegate.switcherRecievedDay(cell: self, flag: switcher.isOn)
    }
    
}
