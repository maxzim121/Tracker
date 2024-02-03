import UIKit

//MARK: - EventSelectionViewControllerDelegate
protocol EventSelectionViewControllerDelegate: AnyObject {
    func eventSelectionViewController(vc: UIViewController,
                                      nameCategories: String,
                                      tracker: Tracker)
    func eventSelectionViewControllerDidCancel(_ vc: EventSelectionViewController)
}

//MARK: - EventSelectionViewController
final class EventSelectionViewController: UIViewController {
    private struct ConstantsEventVc {
        static let textFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let cornerRadius = CGFloat(16)
        static let stackViewSpacing = CGFloat(10)
    }
    
    weak var delegate: EventSelectionViewControllerDelegate?
    private let colors = Colors()
    
    private lazy var labelCreate: UILabel = {
        let labelCreate = UILabel()
        labelCreate.text = Translate.texGreatetLabelName
        labelCreate.font = ConstantsEventVc.textFont
        labelCreate.backgroundColor = .clear
        labelCreate.translatesAutoresizingMaskIntoConstraints = false
        
        return labelCreate
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = ConstantsEventVc.stackViewSpacing
        
        return stackView
    }()
    
    private lazy var habitButton: UIButton = {
        let habitButton = setupButton(text: .habit,
                                      font: ConstantsEventVc.textFont,
                                      cornerRadius: ConstantsEventVc.cornerRadius)
        habitButton.addTarget(self, action: #selector(didTapHabitButton),
                              for: .touchUpInside)
        
        return habitButton
    }()
    
    private lazy var irregularEventButton: UIButton = {
        let irregularEventButton = setupButton(text: .irregularEvent,
                                               font: ConstantsEventVc.textFont,
                                               cornerRadius: ConstantsEventVc.cornerRadius)
        irregularEventButton.addTarget(self,
                                       action: #selector(didTapIrregularEventButton),
                                       for: .touchUpInside)
        
        return irregularEventButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.viewBackground
        setupLableGreate()
        setupStackView()
    }
}

private extension EventSelectionViewController {
    //MARK: - Обработка событий
    @objc
    func didTapHabitButton() {
        let greateVC = createTrackerVC()
        greateVC.reverseIsSchedul()
        present(greateVC, animated: true)
    }
    
    @objc
    func didTapIrregularEventButton() {
        let greateVC = createTrackerVC()
        present(greateVC, animated: true)
    }
    
    func createTrackerVC() -> CreateTrackerViewController {
        let viewModel = EditTrackerViewModel()
        let createVC = CreateTrackerViewController(viewModel: viewModel,
                                                   updateTrackerDelegate: nil,
                                                   createTrackerDelegate: self)
        createVC.modalPresentationStyle = .formSheet
        return createVC
    }
    
    //MARK: - SetupUI
    func setupButton(text: NameEvent,
                     font: UIFont,
                     cornerRadius: CGFloat? = nil) -> UIButton {
        let button = UIButton()
        button.setTitle(text.name, for: .normal)
        button.backgroundColor = colors.buttonEventColor
        button.setTitleColor(.textEventColor, for: .normal)
        button.titleLabel?.font = font
        button.layer.cornerRadius = cornerRadius ?? CGFloat(0)
        button.layer.masksToBounds = cornerRadius == nil ? false : true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
    
    func setupLableGreate() {
        view.addSubview(labelCreate)
        
        NSLayoutConstraint.activate([
            labelCreate.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelCreate.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                             constant: 20),
            labelCreate.heightAnchor.constraint(equalToConstant: labelCreate.font.pointSize)
        ])
    }
    
    func setupStackView() {
        view.addSubview(stackView)
        [habitButton, irregularEventButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                               constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
}

//MARK: - CreateTrackerViewControllerDelegate
extension EventSelectionViewController: CreateTrackerViewControllerDelegate {
    func trackerViewController(vc: UIViewController,
                               nameCategory: String,
                               tracker: Tracker) {
        delegate?.eventSelectionViewController(vc: self,
                                               nameCategories: nameCategory,
                                               tracker: tracker)
    }
    
    func trackerViewControllerDidCancel(_ vc: CreateTrackerViewController) {
        vc.dismiss(animated: false)
        delegate?.eventSelectionViewControllerDidCancel(self)
    }
}
