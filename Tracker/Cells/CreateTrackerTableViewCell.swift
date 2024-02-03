import UIKit

//MARK: - CreateTrackerTableViewCell
class CreateTrackerTableViewCell: UITableViewCell {
    private struct ConstantsCreateCell {
        static let iconButton = "IconButtonCell"
        static let lableFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let choiceButtonSize = CGSize(width: 44, height: 44)
    }
    
    private let colors = Colors()
    
    private lazy var lableView: UILabel = {
        let lableView = UILabel()
        lableView.font = ConstantsCreateCell.lableFont
        
        return lableView
    }()
    
    private lazy var secondaryTextLable: UILabel = {
        let secondaryTextLable = UILabel()
        secondaryTextLable.font =  ConstantsCreateCell.lableFont
        secondaryTextLable.textColor = .grayDay
        secondaryTextLable.isHidden = true
        
        return secondaryTextLable
    }()
    
    private lazy var lableStackView: UIStackView = {
        let lableStackView = UIStackView()
        lableStackView.translatesAutoresizingMaskIntoConstraints = false
        lableStackView.axis = .vertical
        
        return lableStackView
    }()
    
    private lazy var clickImage: UIImageView = {
        let clickImage = UIImageView()
        let image = UIImage(named:  ConstantsCreateCell.iconButton)
        clickImage.image = image
        
        return clickImage
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = colors.viewBackground
        setupUIElement()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assertionFailure("init(coder:) has not been implemented")
    }
    
}

extension CreateTrackerTableViewCell {
    //MARK: - SetupUI
    private func setupUIElement() {
        setupSelf()
        setupSteckView()
    }
    
    private func setupSelf() {
        backgroundColor = .backgroundNight
        layer.masksToBounds = true
        clickImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(clickImage)
        clickImage.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            clickImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                 constant: -12),
            clickImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            clickImage.heightAnchor.constraint(equalToConstant: 24),
            clickImage.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupSteckView() {
        contentView.addSubview(lableStackView)
        [lableView, secondaryTextLable].forEach {
            $0.backgroundColor = .clear
            $0.translatesAutoresizingMaskIntoConstraints = false
            lableStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            lableStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                    constant: 12),
            lableStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    //MARK: - Configuration
    func configCell(choice: ChoiceParametrs) {
        lableView.text = choice.name
    }
    
    func configSecondaryLableShedule(secondaryText: String) {
        if !secondaryText.isEmpty {
            secondaryTextLable.text = secondaryText
            secondaryTextLable.isHidden = false
        }
    }
    
    func setupCornerRadius(cornerRadius: CGFloat, maskedCorners: CACornerMask) {
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = maskedCorners
    }
}
