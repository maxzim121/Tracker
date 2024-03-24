//
//  CustomTableViewCell.swift
//  Tracker
//
//  Created by Maksim Zimens on 03.02.2024.
//

import UIKit

//MARK: - CustomTableViewCell
final class CustomTableViewCell: UITableViewCell {
    private struct ConstantsGreateCell {
        static let iconButton = "IconButtonCell"
        static let nameImageSelected = "selected"
        static let lableFont = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
    private let colors = Colors()
    
    private lazy var nameCategoriLableView: UILabel = {
        let nameCategoriLableView = UILabel()
        nameCategoriLableView.font = ConstantsGreateCell.lableFont
        
        return nameCategoriLableView
    }()
    
    private lazy var selectedImage: UIImageView = {
        let selectedImage = UIImageView()
        let image = UIImage(named: ConstantsGreateCell.nameImageSelected)
        selectedImage.image = image
        selectedImage.backgroundColor = .clear
        selectedImage.isHidden = true
        
        return selectedImage
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        layer.masksToBounds = true
        backgroundColor = colors.viewBackground
        setupLable()
        setupSelectedImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.cornerRadius = 0
        layer.maskedCorners = [.layerMinXMinYCorner,
                               .layerMinXMaxYCorner,
                               .layerMaxXMinYCorner,
                               .layerMaxXMaxYCorner]
    }
}

extension CustomTableViewCell {
    //MARK: - Config
    func config(model: CustomCellModel) {
        nameCategoriLableView.text = model.text
        backgroundColor = model.color
    }
    
    func showSelectedImage(flag: Bool) {
        selectedImage.isHidden = flag
    }
    
    func setupCornerRadius(cornerRadius: CGFloat, maskedCorners: CACornerMask?) {
        layer.cornerRadius = cornerRadius
        guard let maskedCorners else { return }
        layer.maskedCorners = maskedCorners
    }
    
    //MARK: - SetupUI
    private func setupLable() {
        nameCategoriLableView.translatesAutoresizingMaskIntoConstraints = false
        nameCategoriLableView.backgroundColor = .clear
        contentView.addSubview(nameCategoriLableView)
        
        NSLayoutConstraint.activate([
            nameCategoriLableView.centerYAnchor.constraint(equalTo: centerYAnchor),
            nameCategoriLableView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                           constant: 12)
        ])
    }
    
    private func setupSelectedImage() {
        contentView.addSubview(selectedImage)
        selectedImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            selectedImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectedImage.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                    constant: -12)
        ])
    }
}
