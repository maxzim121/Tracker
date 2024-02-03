import UIKit

protocol NewCategoriViewControllerDelegate: AnyObject {
    func didNewCategoryName(_ vc: UIViewController, nameCategory: String)
}

protocol UpdateCategoriViewControllerDelegate: AnyObject {
    func didUpdateCategoryName(_ vc: UIViewController,
                               newNameCategory: String,
                               oldNameCategory: String)
}

//MARK: - NewCategoriViewController
class NewCategoriViewController: UIViewController {
    private struct ConstantsNewCatVc {
        static let cornerRadius = CGFloat(16)
        static let leftIndentTextField = CGFloat(12)
        static let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let textFieldFont = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
    weak var createCategorydelegate: NewCategoriViewControllerDelegate?
    weak var updateCategoryrDelegate: UpdateCategoriViewControllerDelegate?
    
    private var viewModel: NewCategoryViewModelProtocol?
    private let colors = Colors()
    
    private lazy var newCategoriLabel: UILabel = {
        let newCategoriLabel = UILabel()
        newCategoriLabel.text = Translate.newcategoriLabelText
        newCategoriLabel.font = ConstantsNewCatVc.font
        newCategoriLabel.textAlignment = .center
        newCategoriLabel.backgroundColor = .clear
        
        return newCategoriLabel
    }()
    
    private lazy var readyButton: UIButton = {
        let readyButton = UIButton()
        readyButton.setTitle(Translate.buttonName, for: .normal)
        readyButton.setTitleColor(.textEventColor, for: .normal)
        readyButton.isEnabled = false
        readyButton.backgroundColor = .grayDay
        readyButton.titleLabel?.font = ConstantsNewCatVc.font
        readyButton.layer.cornerRadius = ConstantsNewCatVc.cornerRadius
        readyButton.layer.masksToBounds = true
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        readyButton.addTarget(self, action: #selector(didTapNewСategoriButton), for: .touchUpInside)
        
        return readyButton
    }()
    
    private lazy var createNameTextField: UITextField = {
        let createNameTextField = UITextField()
        createNameTextField.delegate = self
        createNameTextField.placeholder = Translate.placeholderCategoryTextField
        createNameTextField.font = ConstantsNewCatVc.textFieldFont
        createNameTextField.indent(size: ConstantsNewCatVc.leftIndentTextField)
        createNameTextField.backgroundColor = .backgroundNight
        createNameTextField.layer.cornerRadius = ConstantsNewCatVc.cornerRadius
        createNameTextField.layer.masksToBounds = true
        createNameTextField.clearButtonMode = .whileEditing
        
        return createNameTextField
    }()
    
    init(createCategorydelegate: NewCategoriViewControllerDelegate? = nil,
         updateCategoryrDelegate: UpdateCategoriViewControllerDelegate? = nil) {
        self.createCategorydelegate = createCategorydelegate
        self.updateCategoryrDelegate = updateCategoryrDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = NewCategoryViewModel()
        bind()
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = colors.viewBackground
        setupUIElement()
    }
}

private extension NewCategoriViewController {
    func bind() {
        guard let viewModel = viewModel as? NewCategoryViewModel else { return }
        viewModel.$newNameCategory.bind { [weak self] text in
            guard let self else { return }
            self.chengeHiddenButton(flag: viewModel.getNewNameCategory().isEmpty)
            self.readyButton.backgroundColor = !text.isEmpty ? self.colors.buttonDisabledColor : .grayDay
            self.readyButton.setTitleColor( !text.isEmpty ? .textEventColor : .whiteDay, for: .normal)
        }
    }
    
    //MARK: - Обработка событий
    @objc
    func didTapNewСategoriButton() {
        guard let viewModel else { return }
        if let createCategorydelegate {
            createCategorydelegate.didNewCategoryName(self,
                                                      nameCategory: viewModel.getNewNameCategory())
        }
        if let updateCategoryrDelegate {
            updateCategoryrDelegate.didUpdateCategoryName(self,
                                                          newNameCategory: viewModel.getNewNameCategory(),
                                                          oldNameCategory: viewModel.getOldNameCategory())
        }
        dismiss(animated: true)
    }
    
    @objc
    private func hideKeyboard() {
        view.endEditing(true)
    }
    
    func chengeHiddenButton(flag: Bool) {
        readyButton.isEnabled = !flag
        readyButton.backgroundColor = !flag ? .blackDay : .grayDay
        readyButton.backgroundColor = flag ? colors.buttonDisabledColor : .grayDay
        readyButton.setTitleColor( flag ? .textEventColor : .whiteDay, for: .normal)
    }
    
    //MARK: - SetupUI
    func setupUIElement() {
        setupCategoriButton()
        setupCategoriLabel()
        setupCreateNameTextField()
    }
    
    func setupCategoriButton() {
        view.addSubview(readyButton)
        
        NSLayoutConstraint.activate([
            readyButton.heightAnchor.constraint(equalToConstant: 60),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -10),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                 constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -20)
        ])
    }
    
    func setupCategoriLabel() {
        view.addSubview(newCategoriLabel)
        newCategoriLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            newCategoriLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                  constant: 24),
            newCategoriLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setupCreateNameTextField() {
        view.addSubview(createNameTextField)
        createNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            createNameTextField.topAnchor.constraint(equalTo: newCategoriLabel.bottomAnchor,
                                                     constant: 24),
            createNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                         constant: 16),
            createNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                          constant: -16),
            createNameTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
}

//MARK: - UITextFieldDelegate
extension NewCategoriViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, let viewModel
        else { return }
        viewModel.setNewNameCategory(text: text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createNameTextField.resignFirstResponder()
        return true
    }
}

extension NewCategoriViewController: SelectCategoryEditViewControllerDelegate {
    func editCategoriesViewController(vc: UIViewController,
                                      oldNameCategory: String) {
        guard let viewModel else { return }
        createNameTextField.text = oldNameCategory
        viewModel.setNewNameCategory(text: oldNameCategory)
        viewModel.setOldNameCategory(text: oldNameCategory)
    }
}
