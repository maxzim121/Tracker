//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Maksim Zimens on 24.01.2024.
//

import Foundation
import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    var colorView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureContentView() {
        configureColorLabel()
        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.layer.cornerRadius = 8
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 42),
            colorView.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    private func configureColorLabel() {
        colorView.layer.cornerRadius = 8
        colorView.layer.masksToBounds = true
    }

    
}
