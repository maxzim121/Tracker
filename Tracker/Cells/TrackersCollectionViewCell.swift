//
//  TrackersCell.swift
//  Tracker
//
//  Created by Maksim Zimens on 12.11.2023.
//

import Foundation
import UIKit

final class TrackersCollectionViewCell: UICollectionViewCell {
    
    private var count: Int = 0
    
    let backGround = UILabel()
    let buttonAndDays = UIStackView()
    let titleLabel = UILabel()
    let emojiLabel = UILabel()
    let doneButton = UIButton()
    let daysLabel = UILabel()
    
    weak var delegate: TrackersCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureTrackerStack()
        configureDaysLabel()
        configureDoneButton()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func configureTrackerStack() {
        contentView.addSubview(backGround)
        backGround.translatesAutoresizingMaskIntoConstraints = false
        backGround.layer.masksToBounds = true
        backGround.layer.cornerRadius = 16
        
        NSLayoutConstraint.activate([
            backGround.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backGround.topAnchor.constraint(equalTo: contentView.topAnchor),
            backGround.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backGround.heightAnchor.constraint(equalToConstant: 90)
        ])
        configureEmojiLabel()
        configureTitleLabel()
    }
    private func configureDaysLabel() {
        contentView.addSubview(daysLabel)
        daysLabel.translatesAutoresizingMaskIntoConstraints = false
        
        daysLabel.font = .systemFont(ofSize: 12)
        daysLabel.text = "\(count) дней"
        
        NSLayoutConstraint.activate([
            backGround.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backGround.topAnchor.constraint(equalTo: contentView.topAnchor),
            backGround.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backGround.heightAnchor.constraint(equalToConstant: 90),
            daysLabel.topAnchor.constraint(equalTo: backGround.bottomAnchor, constant: 8),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.widthAnchor.constraint(equalToConstant: 101),
            daysLabel.heightAnchor.constraint(equalToConstant: 34)
        ])

    }
    
    private func configureDoneButton() {
        doneButton.setImage(UIImage(systemName: "plus"), for: .normal)
        doneButton.tintColor = .white
        contentView.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.layer.cornerRadius = 17
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            doneButton.heightAnchor.constraint(equalToConstant: 34),
            doneButton.topAnchor.constraint(equalTo: backGround.bottomAnchor, constant: 8),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])

    }
    
    private func configureEmojiLabel() {
        emojiLabel.layer.masksToBounds = true
        emojiLabel.textAlignment = .center
        emojiLabel.font = .systemFont(ofSize: 16)
        emojiLabel.adjustsFontSizeToFitWidth = true
        emojiLabel.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        emojiLabel.layer.cornerRadius = 12
        contentView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.leadingAnchor.constraint(equalTo: backGround.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: backGround.topAnchor, constant: 12)
        ])
        
    }
    
    private func configureTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textColor = .white
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: backGround.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: backGround.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: backGround.bottomAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: backGround.bottomAnchor, constant: -46)
        ])
    }
    
    func endingWordDay(count: Int) -> String {
        var result: String
        switch (count % 10) {
        case 1: result = "\(count) день"
        case 2: result = "\(count) дня"
        case 3: result = "\(count) дня"
        case 4: result = "\(count) дня"
        default: result = "\(count) дней"
        }
        return result
    }
    
    func updateLableCountAndImageAddButton(count: Int, flag: Bool) {
        switch flag {
        case true:
            let image = UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysTemplate)
            doneButton.setImage(image, for: .normal)

            self.count = count
            let textLable = endingWordDay(count: count)
            daysLabel.text = textLable
        case false:
            let image = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
            doneButton.setImage(image, for: .normal)

            self.count = count
            let textLable = endingWordDay(count: count)
            daysLabel.text = textLable
        }
    }
    
    private func buttonImageSet(flag: Bool) {
        if flag {
            let image = UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysTemplate)
            doneButton.setImage(image, for: .normal)
        } else {
            let image = UIImage(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
            doneButton.setImage(image, for: .normal)
        }
    }
    
    func updateDaysAndButton(count: Int, isCompleted: Bool) {
        let daysWord = endingWordDay(count: count)
        daysLabel.text = daysWord
        buttonImageSet(flag: isCompleted)
    }
    
    @objc func doneButtonTapped() {
        guard let delegate else { return }
        delegate.didTrackerCompleted(self)
    }

}
