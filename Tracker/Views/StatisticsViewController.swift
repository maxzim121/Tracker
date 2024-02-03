import UIKit

//MARK: - StatisticsViewController
final class StatisticsViewController: UIViewController {
    private struct ConstantsStatisticVC {
        static let imageNothingFound = "NothingFound"
        
        static let borderRadius = CGFloat(16)
        static let borderWidth = CGFloat(2)
        static let fontLabelHeader = UIFont.boldSystemFont(ofSize: 34)
        static let fontLabelTextStub = UIFont.systemFont(ofSize: 12, weight: .medium)
    }
    
    private var viewModel: StatisticsViewModelProtocol?
    private let colors = Colors()
    
    private lazy var labelHeader: UILabel = {
        let labelHeader = UILabel()
        labelHeader.text = Translate.headerStatisticText
        labelHeader.font = ConstantsStatisticVC.fontLabelHeader
        labelHeader.translatesAutoresizingMaskIntoConstraints = false
        labelHeader.backgroundColor = .clear
        
        return labelHeader
    }()
    
    private lazy var cardStatysticsView: StatisticsView = {
        let cardStatistics = StatisticsView()
        cardStatistics.setSecondaryTextLable(text: Translate.secondaryStatisticText)
        cardStatistics.translatesAutoresizingMaskIntoConstraints = false
        cardStatistics.backgroundColor = .clear
        
        return cardStatistics
    }()
    
    private lazy var cardStatysticsViewStack: UIStackView = {
        let cardStatysticsViewStack = UIStackView()
        
        return cardStatysticsViewStack
    }()
    
    private lazy var imageViewStab: UIImageView = {
        let imageViewStab = UIImageView()
        imageViewStab.image = UIImage(named: ConstantsStatisticVC.imageNothingFound)
        
        return imageViewStab
    }()
    
    private lazy var lableTextStab: UILabel = {
        let lableTextStab = UILabel()
        lableTextStab.text = Translate.labelStubStatisticsText
        lableTextStab.font = ConstantsStatisticVC.fontLabelTextStub
        
        return lableTextStab
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.viewBackground
        viewModel = StatisticsViewModel()
        showStabView(flag: viewModel?.getIsTracker())
        bind()
        cardStatysticsView.setCount(count: viewModel?.getCountTrackerComplet() ?? 0)
        setupSubView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addBorderGradient(views: [cardStatysticsView],
                          colors: [UIColor.redGradient.cgColor,
                                   UIColor.greenGradient.cgColor,
                                   UIColor.blueGradient.cgColor],
                          borderWidth: ConstantsStatisticVC.borderWidth,
                          startPoint: CGPoint.centerLeft,
                          endPoint: CGPoint.centerRight,
                          cornerRadius: ConstantsStatisticVC.borderRadius)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showStabView(flag: viewModel?.getIsTracker())
    }
}

private extension StatisticsViewController {
    func bind() {
        guard let viewModel = viewModel as? StatisticsViewModel else { return }
        viewModel.$countTrackerComplet.bind { [weak self] count in
            guard let self else { return }
            self.cardStatysticsView.setCount(count: count ?? 0)
        }
    }
    
    func addBorderGradient(views: [UIView],
                           colors: [CGColor],
                           borderWidth: CGFloat,
                           startPoint: CGPoint,
                           endPoint: CGPoint,
                           cornerRadius: CGFloat) {
        views.forEach {
            $0.layer.cornerRadius = cornerRadius
            $0.clipsToBounds = true
            
            let gradient = CAGradientLayer()
            gradient.frame = $0.bounds
            gradient.colors = colors
            gradient.startPoint = startPoint
            gradient.endPoint = endPoint
            
            let shape = CAShapeLayer()
            shape.lineWidth = borderWidth
            let path = UIBezierPath(roundedRect: $0.bounds,
                                    cornerRadius: cornerRadius).cgPath
            shape.path = path
            shape.strokeColor = UIColor.blackDay.cgColor
            shape.fillColor = UIColor.clear.cgColor
            gradient.mask = shape
            $0.layer.addSublayer(gradient)
        }
    }
    
    func showStabView(flag: Bool?) {
        guard let flag else {
            imageViewStab.isHidden = flag == nil
            lableTextStab.isHidden = flag == nil
            cardStatysticsView.isHidden = flag != nil
            return }
        imageViewStab.isHidden = !flag
        lableTextStab.isHidden = !flag
        cardStatysticsView.isHidden = flag
    }
    
    func setupSubView() {
        setupLabelHeader()
        setupStabView()
        setupCardStatysticsView()
    }
    
    func setupLabelHeader() {
        view.addSubview(labelHeader)
        NSLayoutConstraint.activate([
            labelHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            labelHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44)
        ])
    }
    
    func setupStabView() {
        [imageViewStab, lableTextStab].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
        }
        
        NSLayoutConstraint.activate([
            imageViewStab.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageViewStab.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            lableTextStab.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lableTextStab.topAnchor.constraint(equalTo: imageViewStab.bottomAnchor, constant: 10)
        ])
    }
    
    func setupCardStatysticsView() {
        view.addSubview(cardStatysticsView)
        NSLayoutConstraint.activate([
            cardStatysticsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardStatysticsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardStatysticsView.topAnchor.constraint(equalTo: labelHeader.bottomAnchor, constant: 77),
            cardStatysticsView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
}
