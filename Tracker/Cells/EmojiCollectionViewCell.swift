import UIKit

//MARK: - EmojiCollectionViewCell
final class EmojiCollectionViewCell: UICollectionViewCell {
    private struct ConstantsCell {
        static let cornerRadius = CGFloat(8)
        static let font = UIFont.systemFont(ofSize: 32, weight: .medium)
    }
    
    private var emojiView: UILabel = {
        let emojiView = UILabel()
        emojiView.textAlignment = .center
        emojiView.layer.cornerRadius = ConstantsCell.cornerRadius
        emojiView.layer.masksToBounds = true
        emojiView.backgroundColor = .clear
        emojiView.font = ConstantsCell.font
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        
        return emojiView
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

extension EmojiCollectionViewCell {
    //MARK: - Config
    func configEmoji(emoji: String) {
        emojiView.text = emoji
    }
    
    //MARK: - Selected
    func emojiSelection(isBackground: Bool) {
        emojiView.backgroundColor = isBackground ? .grayDay : .clear
    }
    
    //MARK: - SetupUI
    private func setupColorView() {
        addSubview(emojiView)
        
        NSLayoutConstraint.activate([
            emojiView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emojiView.centerYAnchor.constraint(equalTo: centerYAnchor),
            emojiView.heightAnchor.constraint(equalToConstant: 52),
            emojiView.widthAnchor.constraint(equalToConstant: 52),
        ])
    }
}
