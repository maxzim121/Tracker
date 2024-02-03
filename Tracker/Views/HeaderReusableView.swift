//
//  SupplementaryView.swift
//  Tracker
//
//  Created by Maksim Zimens on 17.01.2024.
//

import UIKit

//MARK: - HeaderReusableView
final class HeaderReusableView: UICollectionReusableView {
    private struct ConstantsHeader {
        static let fontLable = UIFont.boldSystemFont(ofSize: 19)
        static let numberOfLinesLable = 1
    }
    private let colors = Colors()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = ConstantsHeader.fontLable
        label.numberOfLines = ConstantsHeader.numberOfLinesLable
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = colors.viewBackground
        setupLable()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - SetupUI
extension HeaderReusableView {
    private func setupLable() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor,
                                           constant: 12),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setTextLable(text: String) {
        label.text = text
    }
}
