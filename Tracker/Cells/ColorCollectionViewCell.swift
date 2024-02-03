import UIKit

//MARK: - ColorCollectionViewCell
final class ColorCollectionViewCell: UICollectionViewCell {
    private struct ConstantsCell {
        static let cornerRadius = CGFloat(8)
        static let borderWidth = CGFloat(3)
        static let alfaComponent = CGFloat(0.3)
    }
    
    private var contentColorView: UIView = {
        let contentColorView = UIView()
        contentColorView.layer.masksToBounds = true
        contentColorView.translatesAutoresizingMaskIntoConstraints = false
        
        return contentColorView
    }()
    
    private var colorView: UIView = {
        let colorView = UIView()
        colorView.backgroundColor = .clear
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.layer.cornerRadius = ConstantsCell.cornerRadius
        
        return colorView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupColorView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assertionFailure("init(coder:) has not been implemented")
    }
}

extension ColorCollectionViewCell {
    //MARK: - Config
    func configColor(color: UIColor) {
        colorView.backgroundColor = color
    }
    
    func colorSelection(color: UIColor, flag: Bool) {
        contentColorView.layer.cornerRadius = flag ? ConstantsCell.cornerRadius : 0
        contentColorView.layer.borderWidth = flag ? ConstantsCell.borderWidth : 0
        contentColorView.layer.masksToBounds = flag
        contentColorView.layer.borderColor = color.withAlphaComponent(ConstantsCell.alfaComponent).cgColor
    }
    
    //MARK: - SetupUI
    private func setupColorView() {
        addSubview(contentColorView)
        contentColorView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            contentColorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentColorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentColorView.heightAnchor.constraint(equalToConstant: 52),
            contentColorView.widthAnchor.constraint(equalToConstant: 52),
            colorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40),
        ])
    }
}
