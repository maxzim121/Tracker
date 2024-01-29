//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Maksim Zimens on 24.01.2024.
//

import Foundation
import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    var emojiCellLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureContentView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureContentView() {
        configureEmojiLabel()
        contentView.addSubview(emojiCellLabel)
        emojiCellLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 16
        NSLayoutConstraint.activate([
            emojiCellLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiCellLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            
        ])
    }
    
    private func configureEmojiLabel() {
        emojiCellLabel.backgroundColor = .clear
        emojiCellLabel.textAlignment = .center
        emojiCellLabel.layer.cornerRadius = 8
        emojiCellLabel.layer.masksToBounds = true
        emojiCellLabel.font = UIFont.systemFont(ofSize: 32, weight: .medium)
    }
    
    
}
