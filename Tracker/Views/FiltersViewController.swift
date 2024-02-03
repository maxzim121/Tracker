//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Maksim Zimens on 03.02.2024.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func filter(vc: FiltersViewController, filterState: FiltersState)
}

final class FiltersViewController: UIViewController {
    private struct ConstantsFilters {
        static let filterLabelFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let cornerRadiusCell = CGFloat(16)
        static let heightCell = CGFloat(75)
        static let insertSeparatorTableView = UIEdgeInsets(top: .zero,
                                                           left: 12,
                                                           bottom: .zero,
                                                           right: 12)
    }
    
    weak var delegate: FiltersViewControllerDelegate?
    private let viewModel: FiltersViewModelProtocol
    private let colors = Colors()
    
    private lazy var filtersLable: UILabel = {
        let filtersLable = UILabel()
        filtersLable.text = Translate.filtersLableText
        filtersLable.textColor = .blackDay
        filtersLable.font = ConstantsFilters.filterLabelFont
        filtersLable.textAlignment = .center
        filtersLable.backgroundColor = .clear
        
        return filtersLable
    }()
    
    private lazy var filterTableView: UITableView = {
        let filterTableView = UITableView()
        filterTableView.dataSource = self
        filterTableView.delegate = self
        filterTableView.backgroundColor = .clear
        filterTableView.separatorStyle = .singleLine
        filterTableView.separatorColor = .separatorColor
        filterTableView.register(CustomTableViewCell.self,
                                 forCellReuseIdentifier: "\(CustomTableViewCell.self)")
        filterTableView.separatorInset = ConstantsFilters.insertSeparatorTableView
        
        return filterTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = colors.viewBackground
        setupCategoryLabel()
        setupTableView()
    }
    
    init(viewModel: FiltersViewModelProtocol,
         delegate: FiltersViewControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FiltersViewController {
    private func setupCategoryLabel() {
        view.addSubview(filtersLable)
        filtersLable.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filtersLable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                              constant: 24),
            filtersLable.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTableView() {
        view.addSubview(filterTableView)
        filterTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filterTableView.topAnchor.constraint(equalTo: filtersLable.bottomAnchor,
                                                 constant: 24),
            filterTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                     constant: 16),
            filterTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                      constant: -16),
            filterTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

//MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        viewModel.filtersState.count
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        ConstantsFilters.heightCell
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = filterTableView.dequeueReusableCell(withIdentifier: "\(CustomTableViewCell.self)",
                                                             for: indexPath) as? CustomTableViewCell
        else { return UITableViewCell() }
        cell.showSelectedImage(flag: viewModel.comparison(filter: viewModel.filtersState[indexPath.row].rawValue))
        let model = CustomCellModel(text: viewModel.filtersState[indexPath.row].name,
                                    color: .backgroundNight)
        cell.config(model: model)
        if indexPath.row == viewModel.filtersState.count - 1 {
            cell.setupCornerRadius(cornerRadius: ConstantsFilters.cornerRadiusCell,
                                   maskedCorners: [.layerMinXMaxYCorner,
                                                   .layerMaxXMaxYCorner])
            cell.separatorInset = UIEdgeInsets(top: .zero,
                                               left: view.bounds.width,
                                               bottom: .zero,
                                               right: .zero)
        }
        if indexPath.row == .zero {
            cell.setupCornerRadius(cornerRadius: ConstantsFilters.cornerRadiusCell,
                                   maskedCorners: [.layerMaxXMinYCorner,
                                                   .layerMinXMinYCorner])
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard let delegate else { return }
        let selectFilter = viewModel.filtersState[indexPath.row]
        viewModel.setSelectFilter(selectFilter: selectFilter.rawValue)
        delegate.filter(vc: self, filterState: selectFilter)
    }
}
