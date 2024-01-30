//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by Maksim Zimens on 30.01.2024.
//

import Foundation
import UIKit

final class CategoryTableViewCell: UITableViewCell {
    
    private lazy var categoryNameLableView: UILabel = {
        let categoryNameLableView = UILabel()
        categoryNameLableView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        categoryNameLableView.textColor =  UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        
        return categoryNameLableView
    }()
    
    private lazy var selectedImage: UIImageView = {
        let selectedImage = UIImageView()
        let image = UIImage(systemName: "checkmark")
        selectedImage.image = image
        selectedImage.backgroundColor = .clear
        selectedImage.isHidden = true
        
        return selectedImage
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        layer.masksToBounds = true
        setupLable()
        setupSelectedImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.cornerRadius = 0
    }
}

extension CategoryTableViewCell {
    //MARK: - Config
    func config(model: CategoryCellModel) {
        categoryNameLableView.text = model.text
        backgroundColor = model.color
    }
    
    func showSelectedImage(flag: Bool) {
        selectedImage.isHidden = flag
    }
    
    func setupCornerRadius(cornerRadius: CGFloat, maskedCorners: CACornerMask) {
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = maskedCorners
    }
    
    //MARK: - SetupUI
    private func setupLable() {
        categoryNameLableView.translatesAutoresizingMaskIntoConstraints = false
        categoryNameLableView.backgroundColor = .clear
        contentView.addSubview(categoryNameLableView)
        
        NSLayoutConstraint.activate([
            categoryNameLableView.centerYAnchor.constraint(equalTo: centerYAnchor),
            categoryNameLableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12)
        ])
    }
    
    private func setupSelectedImage() {
        contentView.addSubview(selectedImage)
        selectedImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            selectedImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectedImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
    }
}
