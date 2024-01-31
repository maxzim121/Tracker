import Foundation
import UIKit

final class HabbitViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ScheduleDelegate, UITextFieldDelegate, CreateCategoriesViewControllerDelegate {
    func createCategoriesViewController(vc: UIViewController, nameCategory: String) {
        categoryName = nameCategory
        buttonsTable.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        vc.dismiss(animated: true)
    }
    
    
    weak var delegate: TrackerCreationDelegate?
    
    private let recordManager: RecordManagerProtocol = RecordManager.shared
    
    var isHabbit = true
    private var buttonsTableHeight: CGFloat { isHabbit ? 150 : 75}
    private var tableConfiguration: Int { isHabbit ? 2 : 1 }
    private var categoryName = "" { didSet {checkingForEmptiness()}}
    private var habbitSchedule: [WeekDay] = [] { didSet { checkingForEmptiness() } }
    private var selectedEmoji = "" { didSet { checkingForEmptiness() } }
    private var selectedColor: UIColor? { didSet { checkingForEmptiness() } }
    private var nameHabbit: String = ""
    private let emoji: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶",
                                   "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private let colors: [UIColor] = [.colorSelection1, .colorSelection2, .colorSelection3,.colorSelection4,
                                     .colorSelection5, .colorSelection6, .colorSelection7, .colorSelection8,
                                     .colorSelection9, .colorSelection10, .colorSelection11, .colorSelection12,
                                     .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16,
                                     .colorSelection17, .colorSelection18]
    
    private let scheduleVC = RaspisaineViewController()
    
    private let scheduleLableText = NSLocalizedString("scheduleLableText", comment: "")
    private let categoriLabelText = NSLocalizedString("categoriLabelText", comment: "")
    
    private var buttonsLabels: [String] = []
    private var cancelLabel = UILabel()
    private var createLabel = UILabel()
    private var viewLabel = UILabel()
    private var mainScroll = UIScrollView()
    private var trackerNameField = UITextField()
    private var stackView = UIStackView()
    private var buttonsStack = UIStackView()
    private var cancelButton = UIButton()
    private var createButton = UIButton()
    private let colorCollection: UICollectionView = {
        let colorCollection = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        colorCollection.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "Color")
        colorCollection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        return colorCollection
    }()
    private let emojiCollection: UICollectionView = {
        let emojiCollection = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        emojiCollection.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "Emoji")
        emojiCollection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        return emojiCollection
    }()
    private let buttonsTable: UITableView = {
        let buttonsTable = UITableView()
        buttonsTable.register(ButtonCellView.self, forCellReuseIdentifier: "Cell")
        return buttonsTable
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        scheduleVC.delegate = self
        view.backgroundColor = .white
        configureViewLabel()
        configureButtonsStack()
        configureMainScroll()
        if !isHabbit {
            habbitSchedule = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        }
        
    }
    
    private func configureMainScroll() {
        view.addSubview(mainScroll)
        mainScroll.translatesAutoresizingMaskIntoConstraints = false
        mainScroll.contentSize = CGSize(width: 343, height: 765)
        mainScroll.isScrollEnabled = true
        NSLayoutConstraint.activate([
            mainScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainScroll.topAnchor.constraint(equalTo: viewLabel.bottomAnchor),
            mainScroll.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -3)
        ])
        configureStackView()
        configureTextField()
        configureButtonsTabel()
        configureEmojiCollectionView()
        configureColorCollectionView()
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
        trackerNameField.clearButtonMode = .whileEditing
        trackerNameField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        trackerNameField.delegate = self
        
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
            buttonsTable.heightAnchor.constraint(equalToConstant: buttonsTableHeight)
        ])
        buttonsTable.layer.cornerRadius = 16
    }
    
    private func configureButtonsStack() {
        view.addSubview(buttonsStack)
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false
        buttonsStack.axis = .horizontal
        NSLayoutConstraint.activate([
            buttonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            buttonsStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            buttonsStack.heightAnchor.constraint(equalToConstant: 60)
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
        createButton.backgroundColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        createLabel.textColor = .white
        createButton.isEnabled = false
        createButton.alpha = 0.5
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
    
    private func configureEmojiCollectionView() {
        stackView.addArrangedSubview(emojiCollection)
        emojiCollection.delegate = self
        emojiCollection.dataSource = self
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emojiCollection.heightAnchor.constraint(equalToConstant: 222),
            emojiCollection.trailingAnchor.constraint(equalTo: mainScroll.trailingAnchor),
            emojiCollection.leadingAnchor.constraint(equalTo: mainScroll.leadingAnchor)
        ])

    }
    
    private func configureColorCollectionView() {
        stackView.addArrangedSubview(colorCollection)
        colorCollection.backgroundColor = .clear
        
        colorCollection.delegate = self
        colorCollection.dataSource = self
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorCollection.heightAnchor.constraint(equalToConstant: 222),
            colorCollection.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            colorCollection.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
        ])

    }
    
    private func checkingForEmptiness() {
        let flag = !habbitSchedule.isEmpty && !nameHabbit.isEmpty && selectedColor != nil && !selectedEmoji.isEmpty ? true : false
        isActivCreateButton(flag: flag)
    }
    
    private func isActivCreateButton(flag: Bool) {
        createButton.isEnabled = flag
        createButton.alpha = flag ? 1 : 0.5
    }
    
    func scheduleRecieved(schedule: [WeekDay]) {
        habbitSchedule = schedule
        buttonsTable.reloadData()
    }
    
    
    
    @objc func switchToScheduleView() {
        present(scheduleVC, animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let selectedColor else { return }
        let newTracker = Tracker(name: nameHabbit, id: UUID(), color: selectedColor, emoji: selectedEmoji, schedule: habbitSchedule)
        //TODO: Передача нового полного трекера
        delegate?.sendTracker(tracker: newTracker, categoryName: categoryName)
        self.dismiss(animated: false, completion: nil)
        
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        nameHabbit = text
        checkingForEmptiness()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableConfiguration
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = buttonsTable.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ButtonCellView
        buttonsLabels.append(categoriLabelText)
        buttonsLabels.append(scheduleLableText)
        cell.label.text = buttonsLabels[indexPath.row]
        if indexPath.row == 0 {
            if categoryName.isEmpty {
                cell.secondaryLabel.isHidden = true
            } else {
                cell.secondaryLabel.isHidden = false
                cell.secondaryLabel.text = categoryName
            }
        } else {
            if habbitSchedule.isEmpty {
                return cell
            } else {
                cell.secondaryLabel.isHidden = false
                cell.secondaryLabel.text = cell.jonedSchedule(schedule: habbitSchedule)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
            switch indexPath {
            case IndexPath(row: 0, section: 0):
                let categoryViewController = CategoryViewController()
                let viewModel = CategoryViewModel()
                categoryViewController.config(viewModel: viewModel)
                categoryViewController.delegate = self
                present(categoryViewController, animated: true)
            case IndexPath(row: 1, section: 0):
                switchToScheduleView()
            default:
                return
            }
        }
}

extension HabbitViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollection {
            let cell = emojiCollection.dequeueReusableCell(withReuseIdentifier: "Emoji", for: indexPath) as! EmojiCollectionViewCell
            
            cell.emojiCellLabel.text = emoji[indexPath.row]
            return cell
        } else {
            let cell = colorCollection.dequeueReusableCell(withReuseIdentifier: "Color", for: indexPath) as! ColorCollectionViewCell
            
            cell.colorView.backgroundColor = colors[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        if collectionView == emojiCollection {
            let view = emojiCollection.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryView
            view.titleLabel.text = "Emoji"
            return view
        } else {
            let view = colorCollection.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryView
            view.titleLabel.text = "Цвет"
            return view
        }
    }
}

extension HabbitViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorCollection {
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            guard let color = cell?.colorView.backgroundColor else { return }
            cell?.contentView.layer.borderColor = cell?.colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
            cell?.contentView.layer.borderWidth = 2
            selectedColor = color
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            guard let text = cell?.emojiCellLabel.text else { return }
            selectedEmoji = text
            cell?.contentView.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == colorCollection {
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            cell?.contentView.layer.borderColor = UIColor.clear.cgColor
            cell?.contentView.layer.borderWidth = 2
        } else {
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            cell?.contentView.backgroundColor = .clear        }

    }
}

extension HabbitViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 52, height: 52)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {

        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

            
            let indexPath = IndexPath(row: 0, section: section)
            let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
            
            return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                             height: UIView.layoutFittingExpandedSize.height),
                                                             withHorizontalFittingPriority: .required,
                                                      verticalFittingPriority: .fittingSizeLevel)
        }
}
