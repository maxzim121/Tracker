import Foundation
import UIKit

final class PrivichkaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RaspisanieDelegate {
    
    
    weak var delegate: TrackerCreationDelegate?
    
    private let recordManager: RecordManagerProtocol = RecordManager.shared
    private var categoryName = "Категория"
    
    var raspisaniePrivichki: [WeekDay] = []
    var namePrivichka: String = ""
    
    private let raspisanieVC = RaspisaineViewController()
    
    private let buttonsLabels = ["Категория","Расписание"]
    private var cancelLabel = UILabel()
    private var createLabel = UILabel()
    private var viewLabel = UILabel()
    private var mainScroll = UIScrollView()
    private var trackerNameField = UITextField()
    private var stackView = UIStackView()
    private var buttonsStack = UIStackView()
    private var cancelButton = UIButton()
    private var createButton = UIButton()
    private let buttonsTable: UITableView = {
        let buttonsTable = UITableView()
        buttonsTable.register(ButtonCellView.self, forCellReuseIdentifier: "Cell")
        return buttonsTable
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        raspisanieVC.delegate = self
        view.backgroundColor = .white
        configureViewLabel()
        configureMainScroll()
    }
    
    private func configureMainScroll() {
        view.addSubview(mainScroll)
        mainScroll.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainScroll.topAnchor.constraint(equalTo: viewLabel.bottomAnchor),
            mainScroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        configureStackView()
        configureTextField()
        configureButtonsTabel()
        configureButtonsStack()
    }
    
    private func configureStackView() {
        mainScroll.addSubview(stackView)
        stackView.axis = .vertical
        stackView.spacing = 24

        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: mainScroll.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: mainScroll.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: mainScroll.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: mainScroll.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: mainScroll.widthAnchor)
        ])
    }
    
    private func configureTextField() {
        stackView.addArrangedSubview(trackerNameField)
        
        trackerNameField.placeholder = "Введите название теркера"
        trackerNameField.indent(size: CGFloat(12))
        trackerNameField.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        trackerNameField.layer.cornerRadius = 16
        
        NSLayoutConstraint.activate([
            trackerNameField.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            trackerNameField.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            trackerNameField.heightAnchor.constraint(equalToConstant: 75)
        ])
        
    }
    
    private func configureButtonsTabel() {
        buttonsTable.delegate = self
        buttonsTable.dataSource = self
        stackView.addArrangedSubview(buttonsTable)
        NSLayoutConstraint.activate([
            buttonsTable.heightAnchor.constraint(equalToConstant: 150)
        ])
        buttonsTable.layer.cornerRadius = 16
    }
    
    private func configureButtonsStack() {
        view.addSubview(buttonsStack)
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.axis = .horizontal
        NSLayoutConstraint.activate([
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStack.leadingAnchor.constraint(equalTo: mainScroll.leadingAnchor),
            buttonsStack.trailingAnchor.constraint(equalTo: mainScroll.trailingAnchor),
            buttonsStack.heightAnchor.constraint(equalToConstant: 60),
        ])
        buttonsStack.spacing = 8
        configureCancelButton()
        configureCreateButton()
        createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor).isActive = true
    }
    
    private func configureCancelButton() {
        buttonsStack.addArrangedSubview(cancelButton)
        cancelButton.addSubview(cancelLabel)
        cancelButton.backgroundColor = .white
        cancelLabel.text = "Отменить"
        cancelLabel.textAlignment = .center
        cancelLabel.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 16
        cancelLabel.textColor = UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1)
        cancelButton.layer.borderColor = UIColor(red: 0.961, green: 0.42, blue: 0.424, alpha: 1).cgColor
        
        NSLayoutConstraint.activate([
            cancelButton.heightAnchor.constraint(equalTo: buttonsStack.heightAnchor),
            cancelLabel.centerXAnchor.constraint(equalTo: cancelButton.centerXAnchor),
            cancelLabel.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor)
        ])
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    private func configureCreateButton() {
        buttonsStack.addArrangedSubview(createButton)
        createButton.addSubview(createLabel)
        createLabel.translatesAutoresizingMaskIntoConstraints = false
        createLabel.text = "Создать"
        createButton.layer.cornerRadius = 16
        createButton.backgroundColor = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
        createLabel.textColor = .white
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            createButton.heightAnchor.constraint(equalTo: buttonsStack.heightAnchor),
            createLabel.centerXAnchor.constraint(equalTo: createButton.centerXAnchor),
            createLabel.centerYAnchor.constraint(equalTo: createButton.centerYAnchor)
        ])
        
    }
    
    private func configureViewLabel() {
        viewLabel.text = "Новая привычка"
        viewLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewLabel)
        viewLabel.textAlignment = .center
        viewLabel.font = .systemFont(ofSize: 16, weight: .medium)
        viewLabel.textColor = .black
        NSLayoutConstraint.activate([
            viewLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            viewLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            viewLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            viewLabel.heightAnchor.constraint(equalToConstant: 114)
        ])
    }
    
    func raspisanieRecieved(schedule: [WeekDay]) {
        raspisaniePrivichki = schedule
    }
    
    
    
    @objc func switchToRaspisanieView() {
        present(raspisanieVC, animated: true)
    }
    
    @objc private func createButtonTapped() {
        let newTracker = Tracker(name: "name", id: UUID(), color: .red, emoji: "🤣", schedule: raspisaniePrivichki)
        //TODO: Передача нового полного трекера
        delegate?.sendTracker(tracker: newTracker, categoryName: categoryName)
        self.dismiss(animated: false, completion: nil)
        
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = buttonsTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ButtonCellView
        cell.label.text = buttonsLabels[indexPath.row]
        if indexPath.row == 0 {
            cell.secondaryLabel.isHidden = false
            cell.secondaryLabel.text = "Категория"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
            switch indexPath {
            case IndexPath(row: 0, section: 0):
                print("ЗДЕСЬ БУДЕТ ПЕРЕХОД НА ДРУГОЙ ВЬЮ")
            case IndexPath(row: 1, section: 0):
                switchToRaspisanieView()
            default:
                return
            }
        }
}
