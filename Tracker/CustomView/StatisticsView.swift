import UIKit

final class StatisticsView: UIView {
    private struct ConstantsStatistics {
        static let fontLabelHeader = UIFont.boldSystemFont(ofSize: 34)
        static let lableFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        static let cornerRadius = CGFloat(16)
        static let borderWidth = CGFloat(1)
    }
    
    private let colors = Colors()
    
    private lazy var lableHeader: UILabel = {
        let lableHeader = UILabel()
        lableHeader.font = ConstantsStatistics.fontLabelHeader
        
        return lableHeader
    }()
    
    private lazy var secondaryTextLable: UILabel = {
        let secondaryTextLable = UILabel()
        secondaryTextLable.font =  ConstantsStatistics.lableFont
        
        return secondaryTextLable
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        backgroundColor = colors.viewBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StatisticsView {
    private func setupView() {
        [lableHeader, secondaryTextLable].forEach {
            $0.backgroundColor = .clear
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        let indentation = CGFloat(12)
        
        NSLayoutConstraint.activate([
            lableHeader.topAnchor.constraint(equalTo: topAnchor,
                                             constant: indentation),
            lableHeader.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                 constant: indentation),
            secondaryTextLable.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                       constant: -indentation),
            secondaryTextLable.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                        constant: indentation)
        ])
    }
    
    func setCount(count: Int) {
        lableHeader.text = String(count)
    }
    
    func setSecondaryTextLable(text: String) {
        secondaryTextLable.text = text
    }
}
