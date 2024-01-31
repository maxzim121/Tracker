//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Maksim Zimens on 14.10.2023.
//

import Foundation
import UIKit

enum StoreError: Error {
    case modelNotFound
    case failedToLoadPersistentContainer(Error)
    case failedToRecordModel(Error)
    case failedToDeleteModel(Error)
    case failedToUpdateModel(Error)
}

final class TrackersViewController: UIViewController, ReloadDataDelegate, TrackersCollectionViewCellDelegate, DataProviderDelegate {
    
    
    private var recordManager: RecordManagerProtocol = RecordManager.shared
    
    private var dataProvider: DataProviderProtocol?
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    
    private var trackersLabel = UILabel()
    private var sloganLabel = UILabel()
    private var starGrayImage = UIImageView()
    private var searchBar = UISearchBar()
    private var addButton = UIButton()
    private let datePicker = UIDatePicker()
    private var currentDate: Date { datePicker.date }
    private let date = Date()

    private let trackersCollectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(TrackersCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        return collectionView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        dataProvider = try? DataProvider(delegate: self)
        guard let dataProvider else { return }
        completedTrackers = dataProvider.treckersRecords
        categories = dataProvider.trackerCategory
        visibleCategories = categories
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        configureScreen()
        showListTrackersForDay(trackerCategory: categories)
    }
    
    private func configureDatePicker() {
        let format = DateFormatter()
        format.dateFormat = "dd.MM.yyyy"

        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_Ru")
        NSLayoutConstraint.activate([
            datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5)
        ])
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    private func configureAddButton() {
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(named: "AddButtonBlack"), for: .normal)
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 42),
            addButton.heightAnchor.constraint(equalToConstant: 42),
            addButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 6),
            addButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1)
        ])
    }
    
    
    private func configureTrackersLabel() {
        view.addSubview(trackersLabel)
        trackersLabel.translatesAutoresizingMaskIntoConstraints = false
        trackersLabel.text = "Трекеры"
        trackersLabel.font = UIFont.boldSystemFont(ofSize: 34)
        trackersLabel.textColor = .black
        NSLayoutConstraint.activate([
            trackersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 44),
            trackersLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func configureScreen() {
        view.backgroundColor = .white
        configureAddButton()
        configureDatePicker()
        configureTrackersLabel()
        configureSearchBar()
        configureCollectionView()
        configureStarImage()
        configureSloganLabel()
    }
    
    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6),
            searchBar.topAnchor.constraint(equalTo: trackersLabel.bottomAnchor, constant: 0)
        ])
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Поиск"
    }
    
    private func configureStarImage() {
        view.addSubview(starGrayImage)
        starGrayImage.translatesAutoresizingMaskIntoConstraints = false
        starGrayImage.image = UIImage(named: "StarGray")
        NSLayoutConstraint.activate([
            starGrayImage.widthAnchor.constraint(equalToConstant: 80),
            starGrayImage.heightAnchor.constraint(equalTo: starGrayImage.widthAnchor),
            starGrayImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starGrayImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func configureSloganLabel() {
        view.addSubview(sloganLabel)
        sloganLabel.translatesAutoresizingMaskIntoConstraints = false
        sloganLabel.text = "Что будем отслеживать?"
        sloganLabel.font = UIFont.systemFont(ofSize: 12)
        sloganLabel.textAlignment = .center
        NSLayoutConstraint.activate([
            sloganLabel.heightAnchor.constraint(equalToConstant: 18),
            sloganLabel.topAnchor.constraint(equalTo: starGrayImage.bottomAnchor, constant: 8),
            sloganLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureCollectionView() {
        view.addSubview(trackersCollectionView)
        trackersCollectionView.backgroundColor = .white
        trackersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),

        ])
    
    }
    
    private func comparisonWeekDays(date: Date, day: WeekDay) -> Bool {
        FormatDate.shared.greateWeekDayInt(date: date) == day.rawValue
    }
    
    private func filterListTrackersWeekDay(trackerCategory: [TrackerCategory], date: Date) -> [TrackerCategory] {
        var listCategories: [TrackerCategory] = []
        for cat in 0..<trackerCategory.count {
            let currentCategory = trackerCategory[cat]
            var trackers: [Tracker] = []
            for tracker in 0..<trackerCategory[cat].categoryTrackers.count {
                let listWeekDay = trackerCategory[cat].categoryTrackers[tracker].schedule
                for day in 0..<listWeekDay.count {
                    if comparisonWeekDays(date: date, day: listWeekDay[day]) {
                        let tracker = trackerCategory[cat].categoryTrackers[tracker]
                        trackers.append(tracker)
                        break
                    }
                }
            }
            if !trackers.isEmpty {
                let trackerCat = TrackerCategory(categoryName: currentCategory.categoryName, categoryTrackers: trackers)
                listCategories.append(trackerCat)
            }
        }
        return listCategories
    }
    
    private func filterListTrackersName(trackerCategory: [TrackerCategory], word: String) -> [TrackerCategory] {
        let listCategories: [TrackerCategory] = trackerCategory
        var newCategories: [TrackerCategory] = []
        let searchString = word.lowercased()
        listCategories.forEach { category in
            var newTrackers: [Tracker] = []
            category.categoryTrackers.forEach { tracker in
                if tracker.name.lowercased().hasPrefix(searchString) {
                    newTrackers.append(tracker)
                }}
            if !newTrackers.isEmpty {
                let newCategorie = TrackerCategory(categoryName: category.categoryName, categoryTrackers: newTrackers)
                newCategories.append(newCategorie)
            }
        }
        return newCategories
    }
    
    private func showListTrackersForDay(trackerCategory: [TrackerCategory]) {
        let listCategories = filterListTrackersWeekDay(trackerCategory: trackerCategory, date: currentDate)
        guard let dataProvider else { return }
        visibleCategories = dataProvider.trackerCategory
        updateTrackerCollectionView(trackerCategory: listCategories)

    }
    
    private func updateTrackerCollectionView(trackerCategory: [TrackerCategory]) {
        visibleCategories = trackerCategory
        if visibleCategories.isEmpty {
            sloganLabel.isHidden = false
            starGrayImage.isHidden = false
        } else {
            sloganLabel.isHidden = true
            starGrayImage.isHidden = true
        }

        trackersCollectionView.reloadData()
    }
    
    func storeCategory(dataProvider at: DataProvider, indexPath: IndexPath) {
        guard let dataProvider else { return }
        visibleCategories = dataProvider.trackerCategory
        categories = visibleCategories
        showListTrackersForDay(trackerCategory: dataProvider.trackerCategory)
    }
    
    private func showMessageErrorAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(action)
    }
    
    @objc func dateChanged() {
        showListTrackersForDay(trackerCategory: categories)
    }
    
    @objc func addButtonTapped() {
        let trackerCreationVC = TrackerCreationViewController()
        trackerCreationVC.delegate = self
        self.present(trackerCreationVC, animated: true)
    }
    
}
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].categoryTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataProvider,
              let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? TrackersCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.delegate = self
        let tracker = visibleCategories[indexPath.section].categoryTrackers[indexPath.row]
        let dateCompare = Calendar.current.compare(Date(), to: currentDate, toGranularity: .day)
        switch dateCompare {
        case .orderedAscending:
            cell.doneButton.isEnabled = false
        case .orderedSame:
            cell.doneButton.isEnabled = true
        case .orderedDescending:
            cell.doneButton.isEnabled = true
        }
        do {
            cell.backgroundColor = .white
            cell.titleLabel.text = visibleCategories[indexPath.section].categoryTrackers[indexPath.row].name
            cell.emojiLabel.text = visibleCategories[indexPath.section].categoryTrackers[indexPath.row].emoji
            
            cell.backGround.backgroundColor = visibleCategories[indexPath.section].categoryTrackers[indexPath.row].color
            cell.doneButton.backgroundColor = cell.backGround.backgroundColor
            let count = try dataProvider.loadTrackerRecord(id: tracker.id)
            let isCompleted = completedTrackers.contains(where: { $0.id == tracker.id && equalityDates(lDate: currentDate, rDate: $0.date) })
            
            cell.updateDaysAndButton(count: count, isCompleted: isCompleted)
        } catch {
            let errorCount = TrackreRecordStoreError.loadTrackerRecord
            showMessageErrorAlert(message: "\(String(describing: errorCount))")
        }
        
        return cell
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
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryView
        view.titleLabel.text = visibleCategories[indexPath.section].categoryName
        return view
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return visibleCategories.count
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - CGFloat(9)) / 2, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {

        return 9
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

extension TrackersViewController {
    func reloadData(tracker: Tracker, categoryName: String) {
        guard let dataProvider else { return }

        do {
            try dataProvider.addTracker(categoryName, tracker: tracker)
        } catch {
            let updateError = StoreError.failedToUpdateModel(error)
            showMessageErrorAlert(message: "\(updateError)")
        }
        
    }
}

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            showListTrackersForDay(trackerCategory: categories)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let word = searchBar.text else { return }
        if !word.isEmpty {
            let newCategories = filterListTrackersName(trackerCategory: categories, word: word)
            updateTrackerCollectionView(trackerCategory: newCategories)
        } else {
        }
        
    }
    
}


extension TrackersViewController {
    func didTrackerCompleted(_ cell: UICollectionViewCell) {
        guard let trackerCell = cell as? TrackersCollectionViewCell,
              let indexPath = trackersCollectionView.indexPath(for: trackerCell)
        else { return }
        let tracker = visibleCategories[indexPath.section].categoryTrackers[indexPath.row]
        let recordTracker = completedTrackers.first(where: { $0.id == tracker.id && equalityDates(lDate: currentDate, rDate: $0.date) })
        updateCompleted(recordTracker: recordTracker, cell: trackerCell, indexPath: indexPath, flag: recordTracker != nil, tracker: tracker)
    }
    
    private func updateCompleted(recordTracker: TrackerRecord?,
                                 cell: TrackersCollectionViewCell,
                                 indexPath: IndexPath,
                                 flag: Bool,
                                 tracker: Tracker) {
        if let recordTracker {
            do {
                try dataProvider?.deleteTrackerRecord(recordTracker)
            } catch {
                let deleteError = StoreError.failedToRecordModel(error)
                showMessageErrorAlert(message: "\(deleteError)")
            }
            completedTrackers.remove(recordTracker)
            trackersCollectionView.reloadItems(at: [indexPath])
            return
        }
        let newTracker = TrackerRecord(id: tracker.id, date: currentDate)
        do {
            try dataProvider?.addNewTrackerRecord(newTracker)
        } catch {
            let recordError = StoreError.failedToRecordModel(error)
            showMessageErrorAlert(message: "\(recordError)")
        }
        completedTrackers.insert(newTracker)
        trackersCollectionView.reloadItems(at: [indexPath])
    }
    
    func equalityDates(lDate: Date, rDate: Date?) -> Bool {
        guard let dateY = lDate.ignoringTime, let rDate ,let current = rDate.ignoringTime
        else { return false }
        let dateComparison = Calendar.current.compare(dateY , to: current, toGranularity: .day)
        if case .orderedSame = dateComparison {
            return true
        }
        return false
    }
}
