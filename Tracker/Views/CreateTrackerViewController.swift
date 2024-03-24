import UIKit

//MARK: - UpdateTrackerViewControllerDelegate
protocol UpdateTrackerViewControllerDelegate: AnyObject {
    func trackerViewController(vc: UIViewController,
                               nameCategory: String?,
                               tracker: Tracker)
    func trackerViewControllerDidCancel(_ vc: CreateTrackerViewController)
}

//MARK: - CreateTrackerViewControllerDelegate
protocol CreateTrackerViewControllerDelegate: AnyObject {
    func trackerViewController(vc: UIViewController, nameCategory: String, tracker: Tracker)
    func trackerViewControllerDidCancel(_ vc: CreateTrackerViewController)
}

//MARK: - CreateTrackerViewController
final class CreateTrackerViewController: UIViewController {
    private struct ConstantsCreateVc {
        static let emptyString = ""
        
        static let restrictionsTextField = 38
        static let numberOfLinesRestrictionsTextField = 1
        static let heightCollectionView = CGFloat(54)
        
        static let textFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let countСompletedTrackersFont = UIFont.boldSystemFont(ofSize: 32)
        static let createNameTextFieldFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let spacingButtonSpacing = CGFloat(10)
        static let spacingContentStack = CGFloat(24)
        static let leftIndentTextField = CGFloat(12)
        
        static let insertSeparatorTableView = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        static let cornerRadius = CGFloat(16)
        static let borderWidthButton = CGFloat(1)
    }
    
    weak var updateTrackerDelegate: UpdateTrackerViewControllerDelegate?
    weak var createTrackerDelegate: CreateTrackerViewControllerDelegate?
    
    private let viewModel: EditTrackerModelProtocol
    private let colors = Colors()
    private let handler = HandlerResultType()
    
    private lazy var newHabitLabel: UILabel = {
        let newHabitLabel = UILabel()
        newHabitLabel.text = viewModel.isSchedul ? Translate.newIrregular : Translate.newHabit
        newHabitLabel.font = ConstantsCreateVc.textFont
        newHabitLabel.textAlignment = .center
        newHabitLabel.backgroundColor = .clear
        
        return newHabitLabel
    }()
    
    private lazy var countСompletedTrackers: UILabel = {
        let countСompletedTrackers = UILabel()
        countСompletedTrackers.font = ConstantsCreateVc.countСompletedTrackersFont
        countСompletedTrackers.text = setTextCountLable(count: 0)
        
        return countСompletedTrackers
    }()
    
    private lazy var createNameTextField: UITextField = {
        let createNameTextField = UITextField()
        createNameTextField.placeholder = Translate.placeholderTrackerTextField
        createNameTextField.font = ConstantsCreateVc.createNameTextFieldFont
        createNameTextField.indent(size: ConstantsCreateVc.leftIndentTextField)
        createNameTextField.backgroundColor = .backgroundNight
        createNameTextField.layer.cornerRadius = ConstantsCreateVc.cornerRadius
        createNameTextField.layer.masksToBounds = true
        createNameTextField.clearButtonMode = .whileEditing
        createNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        createNameTextField.delegate = self
        
        return createNameTextField
    }()
    
    private lazy var characterRestrictionsView: UILabel = {
        let characterRestrictionsView = UILabel()
        characterRestrictionsView.backgroundColor = .clear
        characterRestrictionsView.font = ConstantsCreateVc.createNameTextFieldFont
        characterRestrictionsView.text = Translate.characterLimit
        characterRestrictionsView.textColor = .redDay
        characterRestrictionsView.numberOfLines = ConstantsCreateVc.numberOfLinesRestrictionsTextField
        characterRestrictionsView.textAlignment = .center
        characterRestrictionsView.isHidden = true
        
        return characterRestrictionsView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView()
        contentStackView.backgroundColor = .clear
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = ConstantsCreateVc.spacingContentStack
        
        return contentStackView
    }()
    
    private lazy var selectionTableView: UITableView = {
        let selectionTableView = UITableView()
        selectionTableView.dataSource = self
        selectionTableView.delegate = self
        selectionTableView.backgroundColor = .clear
        selectionTableView.isScrollEnabled = false
        selectionTableView.separatorColor = .grayDay
        selectionTableView.register(CreateTrackerTableViewCell.self,
                                    forCellReuseIdentifier: "\(CreateTrackerTableViewCell.self)")
        
        return selectionTableView
    }()
    
    private lazy var emojiCollectionView: TrackerCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let params = GeometricParams(cellCount: 7, leftInset: 6, rightInset: 6, cellSpacing: 2)
        let emojiCollectionView = TrackerCollectionView(frame: .zero,
                                                        collectionViewLayout: layout,
                                                        params: params)
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.register(EmojiCollectionViewCell.self,
                                     forCellWithReuseIdentifier: "\(EmojiCollectionViewCell.self)")
        emojiCollectionView.register(HeaderReusableView.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                     withReuseIdentifier: "\(HeaderReusableView.self)")
        emojiCollectionView.allowsMultipleSelection = false
        emojiCollectionView.backgroundColor = .clear
        emojiCollectionView.isScrollEnabled = false
        emojiCollectionView.scrollIndicatorInsets = .zero
        
        return emojiCollectionView
    }()
    
    private lazy var colorCollectionView: TrackerCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let params = GeometricParams(cellCount: 6, leftInset: 6, rightInset: 6, cellSpacing: 2)
        let colorCollectionView = TrackerCollectionView(frame: .zero,
                                                        collectionViewLayout: layout,
                                                        params: params)
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(ColorCollectionViewCell.self,
                                     forCellWithReuseIdentifier: "\(ColorCollectionViewCell.self)")
        colorCollectionView.register(HeaderReusableView.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                     withReuseIdentifier: "\(HeaderReusableView.self)")
        colorCollectionView.allowsMultipleSelection = false
        colorCollectionView.backgroundColor = .clear
        colorCollectionView.isScrollEnabled = false
        colorCollectionView.scrollIndicatorInsets = .zero
        
        return colorCollectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.layer.cornerRadius = ConstantsCreateVc.cornerRadius
        cancelButton.layer.borderWidth = ConstantsCreateVc.borderWidthButton
        cancelButton.layer.borderColor = UIColor.redDay.cgColor
        cancelButton.layer.masksToBounds = true
        cancelButton.backgroundColor = .clear
        cancelButton.setTitle(Translate.textCancelButton , for: .normal)
        cancelButton.setTitleColor(.redDay, for: .normal)
        cancelButton.titleLabel?.font = ConstantsCreateVc.textFont
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        
        return cancelButton
    }()
    
    private lazy var createButton: UIButton = {
        let createButton = UIButton()
        createButton.layer.cornerRadius = ConstantsCreateVc.cornerRadius
        createButton.layer.masksToBounds = true
        createButton.backgroundColor = .grayDay
        createButton.setTitleColor(.whiteDay, for: .normal)
        createButton.setTitle(Translate.textGreateButton, for: .normal)
        createButton.titleLabel?.font = ConstantsCreateVc.textFont
        createButton.isEnabled = false
        createButton.addTarget(self, action: #selector(didTapGreateButton) , for: .touchUpInside)
        
        return createButton
    }()
    
    private lazy var buttonStack: UIStackView = {
        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.spacing = ConstantsCreateVc.spacingButtonSpacing
        buttonStack.distribution = .fillEqually
        
        return buttonStack
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        return contentView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        
        return scrollView
    }()
    
    init(viewModel: EditTrackerModelProtocol,
         updateTrackerDelegate: UpdateTrackerViewControllerDelegate? = nil,
         createTrackerDelegate: CreateTrackerViewControllerDelegate? = nil) {
        self.viewModel = viewModel
        self.updateTrackerDelegate = updateTrackerDelegate
        self.createTrackerDelegate = createTrackerDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setupUIElement()
        view.backgroundColor = colors.viewBackground
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
}

extension CreateTrackerViewController {
    private func bind() {
        guard let viewModel = viewModel as? EditTrackerViewModel else { return }
        viewModel.$schedule.bind { [weak self] _ in
            guard let self else { return }
            self.chengeActivButton()
            self.selectionTableView.reloadData()
        }
        
        viewModel.$color.bind { [weak self] _ in
            guard let self else { return }
            self.chengeActivButton()
        }
        
        viewModel.$emoji.bind { [weak self] _ in
            guard let self else { return }
            self.chengeActivButton()
        }
        
        viewModel.$nameNewCategory.bind { [weak self] _ in
            guard let self else { return }
            self.chengeActivButton()
            self.selectionTableView.reloadData()
        }
        
        viewModel.$nameTracker.bind { [weak self] nameTracker in
            guard let self else { return }
            self.chengeActivButton()
            self.createNameTextField.text = nameTracker
        }
    }
    
    private func chengeActivButton() {
        let flag = self.viewModel.checkingForEmptiness()
        isActivCreateButton(flag: flag)
    }
    
    //MARK: - Обработка событий
    @objc
    private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc
    private func didTapGreateButton() {
        guard let viewModel = viewModel as? EditTrackerViewModel,
              let color = viewModel.color
        else { return }
        if let updateTrackerDelegate = updateTrackerDelegate, let id = viewModel.id {
            let tracker = Tracker(
                id: id,
                name: viewModel.nameTracker,
                color: color,
                emoji: viewModel.emoji,
                schedule: viewModel.isSchedul ? DataSource.regular : viewModel.schedule)
            let nameCategory = viewModel.isPinned ? viewModel.nameNewCategory : nil
            updateTrackerDelegate.trackerViewController(vc: self,
                                                        nameCategory: nameCategory,
                                                        tracker: tracker)
            updateTrackerDelegate.trackerViewControllerDidCancel(self)
            if !viewModel.isPinned {
                self.handler.resultTypeHandler(viewModel.editPinnedCategory(tracker.id,
                                                                            newPinnedCat: viewModel.nameNewCategory),
                                               vc: self) {}
            }
        }
        if let createTrackerDelegate {
            let tracker = Tracker(
                name: viewModel.nameTracker,
                color: color,
                emoji: viewModel.emoji,
                schedule: viewModel.isSchedul ? DataSource.regular : viewModel.schedule)
            createTrackerDelegate.trackerViewController(vc: self,
                                                        nameCategory: viewModel.nameNewCategory,
                                                        tracker: tracker)
            createTrackerDelegate.trackerViewControllerDidCancel(self)
        }
        AnalyticsService.reportEvent(field: MetricEvent(event: .click,
                                                        params: [EventAnalytics.screen.rawValue: Screen.Main.rawValue,
                                                                 EventAnalytics.item.rawValue: ItemClick.add_track.rawValue]))
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text,
              let viewModel = viewModel as? EditTrackerViewModel
        else { return }
        if text.count > ConstantsCreateVc.restrictionsTextField {
            characterRestrictionsView.isHidden = false
            textField.text = viewModel.nameTracker.firstUppercased
            return
        }
        viewModel.setNameTracker(self, nameTracker: text.firstUppercased)
        let flag = viewModel.checkingForEmptiness()
        isActivCreateButton(flag: flag)
    }
    
    @objc
    private func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func isActivCreateButton(flag: Bool) {
        createButton.isEnabled = flag
        createButton.backgroundColor = flag ? colors.buttonDisabledColor : .grayDay
        createButton.setTitleColor( flag ? .textEventColor : .whiteDay, for: .normal)
    }
    
    func reverseIsSchedul() {
        viewModel.reverseIsSchedul()
    }
    
    func setTextCountLable(count: Int) -> String {
        String.localizedStringWithFormat(Translate.numberOfDays,
                                         count)
    }
    
    func presentViewController(vc: UIViewController, modalStyle: UIModalPresentationStyle) {
        vc.modalPresentationStyle = modalStyle
        present(vc, animated: true)
    }
    
    //MARK: - SetupUI
    func setupUIElement() {
        setupNewHabitLabel()
        if updateTrackerDelegate != nil {
            setupCountLabel()
        }
        setupButtonStack()
        setupScrollView()
        setupStackView()
    }
    
    func setupCountLabel() {
        view.addSubview(countСompletedTrackers)
        countСompletedTrackers.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            countСompletedTrackers.topAnchor.constraint(equalTo: newHabitLabel.bottomAnchor,
                                                        constant: 38),
            countСompletedTrackers.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setupNewHabitLabel() {
        view.addSubview(newHabitLabel)
        newHabitLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            newHabitLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: 24),
            newHabitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setupButtonStack() {
        view.addSubview(buttonStack)
        [cancelButton, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            buttonStack.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            buttonStack.heightAnchor.constraint(equalToConstant: 60),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                constant: -10),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                 constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -20)
        ])
    }
    
    func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollTopAnchor = updateTrackerDelegate == nil ?
        newHabitLabel.bottomAnchor :
        countСompletedTrackers.bottomAnchor
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: scrollTopAnchor,
                                            constant: 24),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                 constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor)
        ])
    }
    
    func setupStackView() {
        scrollView.addSubview(contentStackView)
        [createNameTextField, characterRestrictionsView, selectionTableView, emojiCollectionView, colorCollectionView].forEach {
            contentStackView.addArrangedSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            createNameTextField.heightAnchor.constraint(equalToConstant: 75),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 222),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 222),
            selectionTableView.heightAnchor.constraint(equalToConstant: viewModel.isSchedul  ? 75 : 150)
        ])
    }
}

//MARK: - UITableViewDataSource
extension CreateTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModel.listSettings.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(CreateTrackerTableViewCell.self)") as?
                CreateTrackerTableViewCell,
              let viewModel = viewModel as? EditTrackerViewModel
        else { return UITableViewCell() }
        let secondarySchedulText = viewModel.jonedSchedule(schedule: viewModel.schedule,
                                                           stringArrayDay: Translate.everyDay)
        let listSettings = viewModel.listSettings[indexPath.row]
        switch listSettings {
        case .category:
            cell.configCell(choice: listSettings)
            cell.configSecondaryLableShedule(secondaryText: viewModel.nameNewCategory)
        case .schedule:
            cell.configCell(choice: listSettings)
            cell.configSecondaryLableShedule(secondaryText: secondarySchedulText)
        }
        
        if viewModel.isSchedul {
            cell.layer.cornerRadius = ConstantsCreateVc.cornerRadius
        }

        if !viewModel.isSchedul && indexPath.row == 0 {
            cell.setupCornerRadius(cornerRadius: ConstantsCreateVc.cornerRadius,
                                   maskedCorners: [.layerMinXMinYCorner,
                                                   .layerMaxXMinYCorner])
        }

        if !viewModel.isSchedul && indexPath.row == 1 {
            cell.setupCornerRadius(cornerRadius: ConstantsCreateVc.cornerRadius,
                                   maskedCorners: [.layerMinXMaxYCorner,
                                                   .layerMaxXMaxYCorner])
        }
        
        if indexPath.row == 0 {
                    tableView.separatorInset = ConstantsCreateVc.insertSeparatorTableView
                    tableView.separatorStyle = viewModel.isSchedul ? .none : .singleLine
        }
        
        if indexPath.row == 1 {
                        tableView.separatorInset = UIEdgeInsets(top: 0,
                                                                left: view.bounds.width,
                                                                bottom: 0,
                                                                right: 0)
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension CreateTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        switch viewModel.listSettings[indexPath.row] {
        case .category:
            let selectCategoriesViewController = SelectCategoriesViewController(delegate: self,
                                                                                viewModel: CategoryViewModel())
            presentViewController(vc: selectCategoriesViewController,
                                  modalStyle: .formSheet)
        case .schedule:
            let viewModel = SheduleViewModel()
            let scheduleViewController = ScheduleViewController(viewModel: viewModel)
            scheduleViewController.delegate = self
            presentViewController(vc: scheduleViewController, modalStyle: .formSheet)
        }
    }
}

//MARK: - UITextFieldDelegate
extension CreateTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createNameTextField.resignFirstResponder()
        return true
    }
}

//MARK: - UICollectionViewDataSource
extension CreateTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        var count: Int
        switch DataSource.dataSection[section] {
        case .color:
            count = DataSource.colors.count
        case .emoji:
            count = DataSource.emojies.count
        }
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        DataSource.dataSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var returnCell = UICollectionViewCell()
        if collectionView == colorCollectionView,
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(ColorCollectionViewCell.self)",
                                                         for: indexPath) as? ColorCollectionViewCell
        {
            let color = DataSource.colors[indexPath.row]
            cell.configColor(color: color)
            returnCell = cell
        }
        if collectionView == emojiCollectionView,
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(EmojiCollectionViewCell.self)",
                                                         for: indexPath) as? EmojiCollectionViewCell {
            let emoji = DataSource.emojies[indexPath.row]
            cell.configEmoji(emoji: emoji)
            returnCell = cell
        }
        return returnCell
    }
}

//MARK: - UICollectionViewDelegate
extension CreateTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if collectionView == colorCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            else { return }
            let color = DataSource.colors[indexPath.row]
            cell.colorSelection(color: color, flag: true)
            viewModel.setColor(self, color: color)
        }
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            else { return }
            let emoji = DataSource.emojies[indexPath.row]
            cell.emojiSelection(isBackground: true)
            viewModel.setEmojiTracker(self, emoji: emoji)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        if collectionView == colorCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            else { return }
            let color: UIColor = .clear
            cell.colorSelection(color: color, flag: false)
        }
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            else { return }
            cell.emojiSelection(isBackground: false)
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - emojiCollectionView.params.paddingWidth
        let cellWidth = availableWidth / CGFloat(emojiCollectionView.params.cellCount)
        let sizeCell = CGSize(width: cellWidth, height: ConstantsCreateVc.heightCollectionView)
        
        return sizeCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10,
                     left: emojiCollectionView.params.leftInset,
                     bottom: 16,
                     right: emojiCollectionView.params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        var systemLayoutSize: CGSize
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView,
                                             viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
                                             at: indexPath)
        systemLayoutSize = headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                                     height: UIView.layoutFittingExpandedSize.height),
                                                              withHorizontalFittingPriority: .required,
                                                              verticalFittingPriority: .fittingSizeLevel)
        return systemLayoutSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let supplementary = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                  withReuseIdentifier: "\(HeaderReusableView.self)",
                                                                                  for: indexPath) as? HeaderReusableView
        else { return UICollectionReusableView() }
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if collectionView == colorCollectionView {
                supplementary.setTextLable(text: Header.color.name)
            }
            if collectionView == emojiCollectionView {
                supplementary.setTextLable(text: Header.emoji.name)
            }
        default:
            return UICollectionReusableView()
        }
        return supplementary
    }
}

//MARK: - ScheduleViewControllerDelegate
extension CreateTrackerViewController: ScheduleViewControllerDelegate {
    func daysOfWeek(viewController: UIViewController, listDays: [WeekDay]) {
        viewModel.setListWeekDay(listWeekDay: listDays)
    }
}

//MARK: - GreateCategoriesViewControllerDelegate
extension CreateTrackerViewController: SelectCategoriesViewControllerDelegate {
    func categoriesViewController(vc: UIViewController, nameCategory: String) {
        viewModel.setNameNewCategory(self, nameCategory: nameCategory)
        vc.dismiss(animated: true)
    }
}

//MARK: - TrackersViewControllerDelegate
extension CreateTrackerViewController: TrackersViewControllerDelegate {
    func editTracker(vc: TrackersViewController,
                     editTracker: Tracker,
                     count: Int,
                     nameCategory: String,
                     indexPath: IndexPath,
                     isPinned: Bool) {
        let colorRow = viewModel.getColorRow(color: editTracker.color)
        let emojiRow = viewModel.getEmojiRow(emoji: editTracker.emoji)
        countСompletedTrackers.text = setTextCountLable(count: count)
        
        guard let emojiCell = emojiCollectionView.cellForItem(at: IndexPath(row: emojiRow,
                                                                            section: 0)) as? EmojiCollectionViewCell,
              let colorCell = colorCollectionView.cellForItem(at: IndexPath(row: colorRow,
                                                                            section: 0)) as? ColorCollectionViewCell
        else { return }
        viewModel.editTracker(vc: self,
                              editTracker: editTracker,
                              nameCategory: nameCategory,
                              isPinned: isPinned)
        emojiCell.emojiSelection(isBackground: true)
        colorCell.colorSelection(color: editTracker.color, flag: true)
        emojiCollectionView.selectItem(at: IndexPath(row: emojiRow, section: 0),
                                       animated: true,
                                       scrollPosition: UICollectionView.ScrollPosition())
        colorCollectionView.selectItem(at: IndexPath(row: colorRow, section: 0),
                                       animated: true,
                                       scrollPosition: UICollectionView.ScrollPosition())
    }
}
