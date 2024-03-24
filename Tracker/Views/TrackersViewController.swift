//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Maksim Zimens on 14.10.2023.
//

import UIKit

protocol TrackersViewControllerDelegate: AnyObject {
    func editTracker(vc: TrackersViewController,
                     editTracker: Tracker,
                     count: Int,
                     nameCategory: String,
                     indexPath: IndexPath,
                     isPinned: Bool)
}

final class TrackersViewController: UIViewController {
    private struct ConstantsTrackerVc {
        static let adButtonImageName = "Add"
        static let isPinnedImage = "isPinned"
        static let imageStar = "Star"
        static let imageNothingFound = "NothingFound"
        static let forKeyTextCancel = "cancelButtonText"
        
        static let datePickerCornerRadius = CGFloat(8)
        static let buttonFilterCornerRadius = CGFloat(16)
        static let heightCollectionView = CGFloat(148)
        static let cellSpacing = CGFloat(12)
        
        static let fontLableTextStab = UIFont.systemFont(ofSize: 12, weight: .medium)
        static let fontLabelHeader = UIFont.boldSystemFont(ofSize: 34)
        static let fontButtonFilter = UIFont.systemFont(ofSize: 17, weight: .medium)
        
        static let cellCount = 2
        static let firstWeekday = 2
    }
    
    weak var delegate: TrackersViewControllerDelegate?
    private var viewModel: TrackerViewModelProtocol?
    private let handler = HandlerResultType()
    private let colors = Colors()
    
    private lazy var horisontalStack: UIStackView = {
        let horisontalStack = UIStackView()
        horisontalStack.axis = .horizontal
        horisontalStack.alignment = .center
        
        return horisontalStack
    }()
    
    private lazy var averageStack: UIStackView = {
        let averageStack = UIStackView()
        averageStack.backgroundColor = .clear
        averageStack.axis = .vertical
        averageStack.translatesAutoresizingMaskIntoConstraints = false
        
        return averageStack
    }()
    
    private lazy var verticalStack: UIStackView = {
        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        
        return verticalStack
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.backgroundColor = .lightGray
        datePicker.datePickerMode = .date
        datePicker.tintColor = .blueDay
        datePicker.preferredDatePickerStyle = .compact
        datePicker.calendar.firstWeekday = ConstantsTrackerVc.firstWeekday
        datePicker.layer.cornerRadius = ConstantsTrackerVc.datePickerCornerRadius
        datePicker.layer.masksToBounds = true
        datePicker.overrideUserInterfaceStyle = .light
        datePicker.locale = .autoupdatingCurrent
        datePicker.addTarget(self, action: #selector(actionForTapDatePicker), for: .valueChanged)
        
        return datePicker
    }()
    
    private lazy var lableHeader: UILabel = {
        let lableHeader = UILabel()
        lableHeader.text = Translate.headerText
        lableHeader.font = ConstantsTrackerVc.fontLabelHeader
        lableHeader.translatesAutoresizingMaskIntoConstraints = false
        lableHeader.backgroundColor = .clear
        
        return lableHeader
    }()
    
    private lazy var trackerCollectionView: TrackerCollectionView = {
        let trackerCollectionView = greateTrackerCollectionView()
        trackerCollectionView.alwaysBounceVertical = true
        trackerCollectionView.delegate = self
        trackerCollectionView.dataSource = self
        trackerCollectionView.backgroundColor = .clear
        trackerCollectionView.showsVerticalScrollIndicator = false
        trackerCollectionView.allowsMultipleSelection = false
        registerCellAndHeader(collectionView: trackerCollectionView)
        
        
        return trackerCollectionView
    }()
    
    private lazy var imageViewStab: UIImageView = {
        let imageViewStab = UIImageView()
        imageViewStab.image = UIImage(named: ConstantsTrackerVc.imageStar)
        
        return imageViewStab
    }()
    
    private lazy var lableTextStab: UILabel = {
        let lableTextStab = UILabel()
        lableTextStab.text = Translate.labelStabText
        lableTextStab.font = ConstantsTrackerVc.fontLableTextStab
        
        return lableTextStab
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        
        return contentView
    }()
    
    private lazy var buttonFilter: UIButton = {
        let buttonFilter = UIButton()
        buttonFilter.backgroundColor = .blueFilterButton
        buttonFilter.translatesAutoresizingMaskIntoConstraints = false
        buttonFilter.setTitle(Translate.filters, for: .normal)
        buttonFilter.addTarget(self, action: #selector(actionButtonFilter), for: .touchUpInside)
        buttonFilter.titleLabel?.font = ConstantsTrackerVc.fontButtonFilter
        buttonFilter.layer.cornerRadius = ConstantsTrackerVc.buttonFilterCornerRadius
        buttonFilter.layer.masksToBounds = true
        
        return buttonFilter
    }()
    
    init(viewModel: TrackerViewModelProtocol) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        assertionFailure("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.viewBackground
        setupUIElement()
        viewModel = TrackerViewModel()
        bind()
        guard let viewModel = viewModel as? TrackerViewModel else { return }
        setColorButtonFilter(state: viewModel.getFilterState(), button: buttonFilter)
        if let state = viewModel.getSelectFilter() {
            if let state = FiltersState(rawValue: state) {
                filterState(state: state)
            }
        } else {
            viewModel.allTrackersByDate(date: datePicker.date)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AnalyticsService.reportEvent(field: MetricEvent(event: .open,
                                                        params: [EventAnalytics.screen.rawValue: Screen.Main.rawValue]))
    }
}

private extension TrackersViewController {
    func bind() {
        guard let viewModel = viewModel as? TrackerViewModel else { return }
        viewModel.$category.bind { [weak self] _ in
            guard let self else { return }
            self.filterState(state: viewModel.getFilterState())
        }
        
        viewModel.$indexPath.bind { [weak self] indexPath in
            guard let self else { return }
            self.trackerCollectionView.reloadItems(at: [indexPath])
        }
        
        viewModel.$isfilterListTrackersWeekDay.bind { [weak self] flag in
            guard let self, let flag else { return }
            self.buttonFilter.isHidden = !flag
        }
        
        viewModel.$visibleCategory.bind { [weak self] result in
            guard let self,
                  let cat = self.handler.resultTypeHandlerGetValue(result,
                                                              vc: self)
            else { return }
            self.showStabView(flag: !cat.isEmpty)
            self.trackerCollectionView.reloadData()
        }
        
        viewModel.$filterState.bind { [weak self] state in
            guard let self else { return }
            switch state {
            case .allTrackers:
                viewModel.allTrackersByDate(date: self.datePicker.date)
                self.setColorButtonFilter(state: state, button: self.buttonFilter)
            case .toDayTrackers:
                self.datePicker.date = Date()
                viewModel.allTrackersByDate(date: self.datePicker.date)
                self.setColorButtonFilter(state: state, button: self.buttonFilter)
            case .completed:
                viewModel.getCompleted(date: self.datePicker.date, flag: true)
                self.setColorButtonFilter(state: state, button: self.buttonFilter)
            case .notCompleted:
                viewModel.getNotCompleted(date: self.datePicker.date, flag: false)
                self.setColorButtonFilter(state: state, button: self.buttonFilter)
            }
        }
    }
    
    //MARK: - обработка событий
    @objc
    func actionButtonFilter() {
        AnalyticsService.reportEvent(field: MetricEvent(event: .click,
                                                        params: [EventAnalytics.screen.rawValue: Screen.Main.rawValue,
                                                                 EventAnalytics.item.rawValue: ItemClick.filter.rawValue]))
        let filtersVC = FiltersViewController(viewModel: FiltersViewModel(),
                                              delegate: self)
        filtersVC.modalPresentationStyle = .formSheet
        present(filtersVC, animated: true)
    }
    
    @objc
    func actionForTapDatePicker() {
        guard let viewModel else { return }
        filterState(state: viewModel.getFilterState())
    }
    
    @objc
    func didTapLeftNavBarItem() {
        let greateVC = EventSelectionViewController()
        greateVC.delegate = self
        greateVC.modalPresentationStyle = .formSheet
        present(greateVC, animated: true)
    }
    
    func chengeStab(text: String, nameImage: String) {
        lableTextStab.text = text
        imageViewStab.image = UIImage(named: nameImage)
    }
    
    func showStabView(flag: Bool) {
        [imageViewStab, lableTextStab].forEach { $0.isHidden = flag }
    }
    
    func filterState(state: FiltersState) {
        guard let viewModel else { return }
        switch state {
        case .allTrackers:
            viewModel.allTrackersByDate(date: datePicker.date)
            setColorButtonFilter(state: viewModel.getFilterState(),
                                 button: buttonFilter)
        case .toDayTrackers:
            viewModel.allTrackersByDate(date: datePicker.date)
            setColorButtonFilter(state: viewModel.getFilterState(),
                                 button: buttonFilter)
        case .completed:
            viewModel.getCompleted(date: datePicker.date, flag: true)
            setColorButtonFilter(state: viewModel.getFilterState(),
                                 button: buttonFilter)
        case .notCompleted:
            viewModel.getNotCompleted(date: datePicker.date, flag: false)
            setColorButtonFilter(state: viewModel.getFilterState(),
                                 button: buttonFilter)
        }
    }
    
    func setColorButtonFilter(state: FiltersState, button: UIButton) {
        button.setTitleColor(state == .allTrackers ? .colorSelection9 : .colorSelection1, for: .normal)
    }
    
    func greateTrackerCollectionView() -> TrackerCollectionView {
        let params = GeometricParams(cellCount: ConstantsTrackerVc.cellCount,
                                     leftInset: .zero,
                                     rightInset: .zero,
                                     cellSpacing: ConstantsTrackerVc.cellSpacing)
        let layout = UICollectionViewFlowLayout()
        let trackerCollectionView = TrackerCollectionView(frame: .zero,
                                                          collectionViewLayout: layout,
                                                          params: params)
        return trackerCollectionView
    }
    
    func registerCellAndHeader(collectionView: TrackerCollectionView) {
        collectionView.register(TrackersCollectionViewCell.self,
                                forCellWithReuseIdentifier: "\(TrackersCollectionViewCell.self)")
        collectionView.register(HeaderReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "\(HeaderReusableView.self)")
    }
    
    //MARK: - Menu Action
    func pinnedAction(text: String, tracker: Tracker, category: TrackerCategory) -> UIAction {
        UIAction(title: text) { [weak self] _ in
            guard let self else { return }
            guard let viewModel = self.viewModel else { return }
            guard let cat = self.handler.resultTypeHandlerGetValue(viewModel.getCategory(),
                                                                   vc: self)
            else { return }
            if category.isPinned {
                self.handler.resultTypeHandler(viewModel.addPinnedCategory(id: tracker.id,
                                                                      nameCategory: category.nameCategory),
                                          vc: self) {
                    self.handler.resultTypeHandler(viewModel.deleteTracker(id: tracker.id),
                                                   vc: self) {}
                }
                let filterNameCategory = cat.filter { $0.nameCategory == Translate.textFixed }
                if let _ = filterNameCategory.first?.nameCategory {
                    self.handler.resultTypeHandler(viewModel.addNewTracker(tracker,
                                                                           nameCategory: Translate.textFixed),
                                                   vc: self) {}
                } else {
                    self.handler.resultTypeHandler(viewModel.addCategory(nameCategory: Translate.textFixed),
                                                   vc: self) {
                        self.handler.resultTypeHandler(viewModel.addNewTracker(tracker,
                                                                               nameCategory: Translate.textFixed),
                                                       vc: self) {}
                    }
                }
            } else {
                if let nameCategory = self.handler.resultTypeHandlerGetValue(viewModel.deleteAndGetPinnedCategory(id: tracker.id),
                                                                        vc: self) {
                    self.handler.resultTypeHandler(viewModel.deleteTracker(id: tracker.id),
                                                   vc: self) {}
                    if let category = self.handler.resultTypeHandlerGetValue(viewModel.category,
                                                                        vc: self)?.filter({ $0.nameCategory == nameCategory }).first {
                        self.handler.resultTypeHandler(viewModel.addNewTracker(tracker, nameCategory: category.nameCategory), vc: self) {}
                    } else {
                        guard let nameCategory else { return }
                        self.handler.resultTypeHandler(viewModel.addCategory(nameCategory: nameCategory),
                                                       vc: self) {
                            self.handler.resultTypeHandler(viewModel.addNewTracker(tracker,
                                                                                   nameCategory: nameCategory),
                                                           vc: self) {}
                        }
                    }
                }
            }
        }
    }
    
    func editTrackerAction(text: String,
                           tracker: Tracker,
                           category: TrackerCategory,
                           indexPath: IndexPath) -> UIAction {
        UIAction(title: text) { [weak self] _ in
            guard let self else { return }
            guard let viewModel = self.viewModel else { return }
            let editViewModel = EditTrackerViewModel()
            let createTrackerVC = CreateTrackerViewController(viewModel: editViewModel,
                                                              updateTrackerDelegate: self)
            self.delegate = createTrackerVC
            if tracker.schedule.count != DataSource.regular.count {
                createTrackerVC.reverseIsSchedul()
            }
            createTrackerVC.modalPresentationStyle = .formSheet
            self.present(createTrackerVC, animated: true) {
                let count = self.handler.resultTypeHandlerGetValue(viewModel.getCountTrackerCompleted(id: tracker.id),
                                                                   vc: self)
                let pinnedCategory = self.handler.resultTypeHandlerGetValue(viewModel.getPinnedCategory(tracker.id),
                                                                            vc: self)
                let nameCategory = category.isPinned ? category.nameCategory : pinnedCategory
                guard let count
                else { return }
                self.delegate?.editTracker(vc: self,
                                           editTracker: tracker,
                                           count: count,
                                           nameCategory: (nameCategory ?? category.nameCategory) ?? category.nameCategory,
                                           indexPath: indexPath,
                                           isPinned: category.isPinned)
            }
            AnalyticsService.reportEvent(field: MetricEvent(event: .click,
                                                            params: [EventAnalytics.screen.rawValue: Screen.Main.rawValue,
                                                                     EventAnalytics.item.rawValue: ItemClick.edit.rawValue]))
        }
    }
    
    func deleteAction(text: String, tracker: Tracker) -> UIAction {
        UIAction(title: text, attributes: .destructive) { [weak self] _ in
            guard let self else { return }
            guard let viewModel = self.viewModel else { return }
            let alert = UIAlertController(title: nil,
                                          message: Translate.sureDeleteTracker,
                                          preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: Translate.textDelete,
                                             style: .destructive) { _ in
                
                self.handler.resultTypeHandler(viewModel.deleteTrackersRecord(id: tracker.id),
                                               vc: self) {}
                self.handler.resultTypeHandler(viewModel.deleteTracker(id: tracker.id),
                                               vc: self) {}
                AnalyticsService.reportEvent(field: MetricEvent(event: .click,
                                                                params: [EventAnalytics.screen.rawValue: Screen.Main.rawValue,
                                                                         EventAnalytics.item.rawValue: ItemClick.edit.rawValue]))
            }
            let cancelAction = UIAlertAction(title: Translate.textCancel,
                                             style: .cancel) { _ in
                alert.dismiss(animated: true)
            }
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        }
    }
    
    //MARK: - SetupUI
    func setupUIElement() {
        setupVerticalSteck()
        setupContentView()
        setupStabView()
        setupNavBarItem()
        setupButtonFilter()
    }
    
    func setupNavBarItem() {
        guard let navBar = navigationController?.navigationBar,
              let topItem = navBar.topItem
        else { return }
        topItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: ConstantsTrackerVc.adButtonImageName),
                                                    style: .plain, target: self,
                                                    action: #selector(didTapLeftNavBarItem))
        
        topItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        topItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: .zero, left: -10, bottom: .zero, right: .zero)
        topItem.leftBarButtonItem?.tintColor = colors.whiteBlackItemColor
        navBar.backgroundColor = .clear
        
        navigationItem.title = Translate.headerText
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let searcheController = UISearchController(searchResultsController: nil)
        searcheController.searchResultsUpdater = self
        searcheController.obscuresBackgroundDuringPresentation = false
        searcheController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searcheController
        searcheController.searchBar.placeholder = Translate.placeholderSearch
        searcheController.searchBar.resignFirstResponder()
        searcheController.searchBar.returnKeyType = .search
        searcheController.searchBar.setValue(Translate.textCancel,
                                             forKey: ConstantsTrackerVc.forKeyTextCancel)
    }
    
    func setupContentView() {
        trackerCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(trackerCollectionView)
        
        NSLayoutConstraint.activate([
            trackerCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            trackerCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func setupVerticalSteck() {
        view.addSubview(verticalStack)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        verticalStack.addArrangedSubview(contentView)
        
        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            verticalStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            verticalStack.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                   constant: 16),
            verticalStack.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                    constant: -16)
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
            lableTextStab.topAnchor.constraint(equalTo: imageViewStab.bottomAnchor,
                                               constant: 10)
        ])
    }
    
    func setupButtonFilter() {
        view.addSubview(buttonFilter)
        
        NSLayoutConstraint.activate([
            buttonFilter.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonFilter.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                 constant: -16),
            buttonFilter.heightAnchor.constraint(equalToConstant: 50),
            buttonFilter.widthAnchor.constraint(equalToConstant: 114)
        ])
    }
}

//MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel as? TrackerViewModel,
              let itemsCount = handler.resultTypeHandlerGetValue(viewModel.visibleCategory,
                                                                 vc: self)?[section].arrayTrackers.count
        else { return .zero }
        return itemsCount
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let viewModel = viewModel as? TrackerViewModel,
              let sectionCount = handler.resultTypeHandlerGetValue(viewModel.visibleCategory,
                                                                   vc: self)?.count
        else { return .zero }
        return sectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TrackersCollectionViewCell.self)",
                                                            for: indexPath) as? TrackersCollectionViewCell,
              let viewModel = viewModel as? TrackerViewModel,
              let visibleCategories = handler.resultTypeHandlerGetValue(viewModel.visibleCategory,
                                                                        vc: self)
        else { return UICollectionViewCell() }
        cell.delegate = self
        let tracker = visibleCategories[indexPath.section].arrayTrackers[indexPath.row]
        let dateComparison = Calendar.current.compare(Date(),
                                                      to: datePicker.date,
                                                      toGranularity: .day)
        switch dateComparison {
        case .orderedAscending:
            cell.isEnableAddButton(flag: false)
            cell.updateBackgraundAddButton(isHidden: false)
        case .orderedSame:
            cell.isEnableAddButton(flag: true)
            cell.updateBackgraundAddButton(isHidden: true)
        case .orderedDescending:
            cell.isEnableAddButton(flag: true)
            cell.updateBackgraundAddButton(isHidden: true)
        }
        cell.setPinned(flag: visibleCategories[indexPath.section].isPinned)
        handler.resultTypeHandler(viewModel.loadTrackerRecord(id: tracker.id),
                                  vc: self) { [weak self] count in
            guard let self,
                  let isComplited = self.handler.resultTypeHandlerGetValue(viewModel.getIsComplited(tracker: tracker,
                                                                                                    date: self.datePicker.date),
                                                                           vc: self)
            else { return }
            let updateModel = UpdateTracker(count: count,
                                            flag: isComplited)
            cell.config(tracker: tracker)
            cell.updateLableCountAndImageAddButton(updateModel)
        }
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfiguration configuration: UIContextMenuConfiguration,
                        highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let cell = trackerCollectionView.cellForItem(at: indexPath) as? TrackersCollectionViewCell
        else { return nil }
        let previewTarget = UIPreviewTarget(container: self.trackerCollectionView,
                                            center: cell.center)
        return .init(view: cell.getView(),
                     parameters: UIPreviewParameters(),
                     target: previewTarget)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let flag = viewModel?.getIsCategoryForDay(), flag else { return }
        let offsetY = scrollView.contentOffset.y
        if offsetY > 0 {
            // Прокрутка вниз - скрыть кнопку
            buttonFilter.isHidden = true
            trackerCollectionView.contentInset.bottom = buttonFilter.bounds.height
        } else {
            // Прокрутка вверх или в самый верх - показать кнопку
            buttonFilter.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first,
              let viewModel,
              let visibleCategories = handler.resultTypeHandlerGetValue(viewModel.visibleCategory,
                                                                        vc: self)
        else { return nil }
        let selectorCategory = visibleCategories[indexPath.section]
        let selectedTracker = selectorCategory.arrayTrackers[indexPath.row]
        let firstContextText = !selectorCategory.isPinned ? Translate.textUnpin : Translate.textFix
        let secondContentText = Translate.textEdit
        let thirdContentText = Translate.textDelete
        return UIContextMenuConfiguration(actionProvider:  { [weak self] _ in
            guard let self else { return UIMenu() }
            return UIMenu(children: [
                self.pinnedAction(text: firstContextText,
                                  tracker: selectedTracker,
                                  category: selectorCategory),
                self.editTrackerAction(text: secondContentText,
                                       tracker: selectedTracker,
                                       category: selectorCategory,
                                       indexPath: indexPath),
                self.deleteAction(text: thirdContentText, tracker: selectedTracker)
            ])
        })
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - trackerCollectionView.params.paddingWidth
        let cellWidth = availableWidth / CGFloat(trackerCollectionView.params.cellCount)
        let sizeCell = CGSize(width: cellWidth, height: ConstantsTrackerVc.heightCollectionView)
        
        return sizeCell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: trackerCollectionView.params.leftInset,
                     bottom: 16, right: trackerCollectionView.params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let viewModel = viewModel as? TrackerViewModel,
              let visibleCategories = handler.resultTypeHandlerGetValue(viewModel.visibleCategory,
                                                                        vc: self)
        else { return CGSize() }
        let indexPath = IndexPath(row: visibleCategories.count, section: section)
        let headerView = self.collectionView(collectionView,
                                             viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
                                             at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let supplementary = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                      withReuseIdentifier: "\(HeaderReusableView.self)",
                                                                                      for: indexPath) as? HeaderReusableView,
                  let viewModel = viewModel as? TrackerViewModel,
                  let visibleCategories = handler.resultTypeHandlerGetValue(viewModel.visibleCategory, vc: self)
            else { return UICollectionReusableView() }
            let nameCategory = visibleCategories[indexPath.section].nameCategory
            if nameCategory == Fixed.fixedRu.rawValue || nameCategory == Fixed.fixedEng.rawValue {
                supplementary.setTextLable(text: Translate.textFixed)
                return supplementary
            }
            supplementary.setTextLable(text: nameCategory)
            return supplementary
        default:
            return UICollectionReusableView()
        }
    }
}

//MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let word = searchController.searchBar.text,
              let viewModel
        else { return }
        if !word.isEmpty {
            guard let seachCategory = handler.resultTypeHandlerGetValue(viewModel.filterListTrackersName(word: word),
                                                                        vc: self)
            else { return }
            viewModel.getShowListTrackerSearchForName(seachCategory)
            return
        }
        
        if word.isEmpty {
            let _ = viewModel.getShowListTrackersForDay(date: datePicker.date)
            chengeStab(text: Translate.labelNothingFoundText,
                       nameImage: ConstantsTrackerVc.imageNothingFound)
        }
        
        if !searchController.isActive {
            let _ = viewModel.getShowListTrackersForDay(date: datePicker.date)
            chengeStab(text: Translate.labelStabText,
                       nameImage: ConstantsTrackerVc.imageStar)
        }
    }
}

//MARK: - TrackersCollectionViewCellDelegate
extension TrackersViewController: TrackersCollectionViewCellDelegate {
    func didTrackerCompleted(_ cell: UICollectionViewCell) {
        guard let trackerCell = cell as? TrackersCollectionViewCell,
              let indexPath = trackerCollectionView.indexPath(for: trackerCell),
              let viewModel = viewModel as? TrackerViewModel,
              let visibleCategories = handler.resultTypeHandlerGetValue(viewModel.visibleCategory,
                                                                        vc: self)
        else { return }
        let tracker = visibleCategories[indexPath.section].arrayTrackers[indexPath.row]
        viewModel.setIndexPath(indexPath)
        handler.resultTypeHandler(viewModel.updateCompletedTrackers(tracker: tracker,
                                                                    date: datePicker.date),
                                  vc: self) {}
        AnalyticsService.reportEvent(field: MetricEvent(event: .click,
                                                        params: [EventAnalytics.screen.rawValue: Screen.Main.rawValue,
                                                                 EventAnalytics.item.rawValue: ItemClick.track.rawValue]))
    }
}

//MARK: - EventSelectionViewControllerDelegate
extension TrackersViewController: EventSelectionViewControllerDelegate {
    func eventSelectionViewController(vc: UIViewController,
                                      nameCategories: String,
                                      tracker: Tracker) {
        guard let viewModel else { return }
        handler.resultTypeHandler(viewModel.addNewTracker(tracker,
                                                          nameCategory: nameCategories),
                                  vc: self) {}
    }
    
    func eventSelectionViewControllerDidCancel(_ vc: EventSelectionViewController) {
        vc.dismiss(animated: false)
    }
}

//MARK: - UpdateTrackerViewControllerDelegate
extension TrackersViewController: UpdateTrackerViewControllerDelegate {
    func trackerViewController(vc: UIViewController,
                               nameCategory: String?,
                               tracker: Tracker) {
        guard let viewModel else { return }
        handler.resultTypeHandler(viewModel.updateTracker(tracker: tracker,
                                                          nameCategory: nameCategory),
                                  vc: self) {}
    }
    
    func trackerViewControllerDidCancel(_ vc: CreateTrackerViewController) {
        vc.dismiss(animated: true)
    }
}

//MARK: - FiltersViewControllerDelegate
extension TrackersViewController: FiltersViewControllerDelegate {
    func filter(vc: FiltersViewController, filterState: FiltersState) {
        guard let viewModel else { return }
        viewModel.setFilterState(state: filterState)
        vc.dismiss(animated: true)
    }
}
