//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Maksim Zimens on 30.01.2024.
//

import UIKit

//MARK: - SelectCategoriesViewControllerDelegate
protocol SelectCategoriesViewControllerDelegate: AnyObject {
    func categoriesViewController(vc: UIViewController, nameCategory: String)
}

//MARK: - SelectCategoryEditViewControllerDelegate
protocol SelectCategoryEditViewControllerDelegate: AnyObject {
    func editCategoriesViewController(vc: UIViewController, oldNameCategory: String)
}

//MARK: - SelectCategoriesViewController
final class SelectCategoriesViewController: UIViewController {
    private struct ConstantsCreateCatVc {
        static let imageViewImageStab = "Star"
        static let lableTextStabNumberOfLines = 2
        static let one = 1
        static let selectionCategoryTableViewRowHeight = CGFloat(75)
        static let cornerRadius = CGFloat(16)
        static let categoryLabelFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let labelStabTextFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        static let lableFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let insertSeparatorTableView = UIEdgeInsets(top: .zero, left: 12, bottom: .zero, right: 12)
    }
    
    weak var delegate: SelectCategoriesViewControllerDelegate?
    weak var editDelegate: SelectCategoryEditViewControllerDelegate?
    private var viewModel: CategoryViewModelProtocol
    
    private let handler = HandlerResultType()
    private let colors = Colors()
    
    private lazy var categoryLabel: UILabel = {
        let categoryLabel = UILabel()
        categoryLabel.text = Translate.categoryLabelText
        categoryLabel.textColor = .blackDay
        categoryLabel.font = ConstantsCreateCatVc.categoryLabelFont
        categoryLabel.textAlignment = .center
        categoryLabel.backgroundColor = .clear
        
        return categoryLabel
    }()
    
    private lazy var imageViewStab: UIImageView = {
        let imageViewStab = UIImageView()
        let image = UIImage(named: ConstantsCreateCatVc.imageViewImageStab)
        imageViewStab.image = image
        
        return imageViewStab
    }()
    
    private lazy var lableTextStab: UILabel = {
        let lableTextStab = UILabel()
        lableTextStab.text = Translate.labelStabText
        lableTextStab.font = ConstantsCreateCatVc.labelStabTextFont
        lableTextStab.numberOfLines = ConstantsCreateCatVc.lableTextStabNumberOfLines
        lableTextStab.textAlignment = .center
        
        return lableTextStab
    }()
    
    private lazy var conteinerStabView: UIView = {
        let conteinerStabView = UIView()
        conteinerStabView.translatesAutoresizingMaskIntoConstraints = false
        conteinerStabView.backgroundColor = .clear
        conteinerStabView.isHidden = false
        
        return conteinerStabView
    }()
    
    private lazy var selectionCategoryTableView: UITableView = {
        let selectionCategoryTableView = UITableView()
        selectionCategoryTableView.dataSource = self
        selectionCategoryTableView.delegate = self
        selectionCategoryTableView.backgroundColor = .clear
        selectionCategoryTableView.separatorStyle = .singleLine
        selectionCategoryTableView.separatorColor = .separatorColor
        selectionCategoryTableView.register(CustomTableViewCell.self,
                                            forCellReuseIdentifier: "\(CustomTableViewCell.self)")
        selectionCategoryTableView.separatorInset = ConstantsCreateCatVc.insertSeparatorTableView
        
        return selectionCategoryTableView
    }()
    
    private lazy var createCategoryButton: UIButton = {
        let createCategoryButton = UIButton()
        createCategoryButton.setTitle(Translate.categoryAddButtonText, for: .normal)
        createCategoryButton.setTitleColor(.textEventColor, for: .normal)
        createCategoryButton.backgroundColor = colors.buttonDisabledColor
        createCategoryButton.titleLabel?.font = ConstantsCreateCatVc.lableFont
        createCategoryButton.layer.cornerRadius = ConstantsCreateCatVc.cornerRadius
        createCategoryButton.layer.masksToBounds = true
        createCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        createCategoryButton.addTarget(self, action: #selector(didTapСategoryButton),
                                       for: .touchUpInside)
        
        return createCategoryButton
    }()
    
    init(delegate: SelectCategoriesViewControllerDelegate,
         viewModel: CategoryViewModelProtocol) {
        self.delegate = delegate
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel as? CategoryViewModel else { return }
        setupUIElement()
        bind()
        view.backgroundColor = colors.viewBackground
        handler.resultTypeHandler(viewModel.сategoryExcludingFixed(), vc: self) { [weak self] cat in
            guard let self else { return }
            self.showStabView(flag: !cat.isEmpty)
        }
        selectionCategoryTableView.rowHeight = ConstantsCreateCatVc.selectionCategoryTableViewRowHeight
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
}

extension SelectCategoriesViewController {
    //MARK: - обработка событий
    @objc
    private func didTapСategoryButton() {
        let newCategoryVC = NewCategoriViewController(createCategorydelegate: self)
        newCategoryVC.modalPresentationStyle = .formSheet
        present(newCategoryVC, animated: true)
    }
    
    private func showStabView(flag: Bool) {
        conteinerStabView.isHidden = flag
    }
    
    private func bind() {
        guard let viewModel = viewModel as? CategoryViewModel else { return }
        viewModel.$category.bind { [weak self] _ in
            guard let self else { return }
            self.handler.resultTypeHandler(viewModel.сategoryExcludingFixed(), vc: self) { cat in
                self.showStabView(flag: !cat.isEmpty)
            }
            self.selectionCategoryTableView.reloadData()
        }
    }
    
    private func editAction(text: String,
                            category: TrackerCategory) -> UIAction {
        UIAction(title: text) { [weak self] _ in
            guard let self else { return }
            let newCategoryVC = NewCategoriViewController(updateCategoryrDelegate: self)
            self.editDelegate = newCategoryVC
            newCategoryVC.modalPresentationStyle = .formSheet
            self.present(newCategoryVC, animated: true) {
                self.editDelegate?.editCategoriesViewController(vc: self,
                                                                oldNameCategory: category.nameCategory)
            }
        }
    }
    
    private func deleteAction(text: String,
                              category: TrackerCategory,
                              index: Int,
                              trackers: [Tracker]) -> UIAction {
        UIAction(title: text, attributes: .destructive) { [weak self] _ in
            guard let self else { return }
            let alert = UIAlertController(title: nil,
                                          message: Translate.alertDeleteCategoryMessage,
                                          preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: Translate.textDelete,
                                             style: .destructive) { _ in
                if let isCategorySelected =  self.handler.resultTypeHandlerGetValue(self.viewModel.isCategorySelected(at: index),
                                                                                    vc: self),
                   !isCategorySelected {
                    self.viewModel.deleteSelectCategory()
                }
                self.handler.resultTypeHandler(self.viewModel.deleteCategory(nameCategory: category.nameCategory),
                                               vc: self) {
                    self.handler.resultTypeHandler(self.viewModel.deleteTrackers(trackers: category.arrayTrackers),
                                                   vc: self) {
                        self.handler.resultTypeHandler(self.viewModel.deleteTrackerRecords(trackers: trackers),
                                                       vc: self) {}
                    }
                }
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
    private func setupUIElement() {
        setupCategoryButton()
        setupCategoryLabel()
        setupTableView()
        setupStabView()
    }
    
    private func setupCategoryButton() {
        view.addSubview(createCategoryButton)
        
        NSLayoutConstraint.activate([
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            createCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupCategoryLabel() {
        view.addSubview(categoryLabel)
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                               constant: 24),
            categoryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTableView() {
        view.addSubview(selectionCategoryTableView)
        selectionCategoryTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            selectionCategoryTableView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor,
                                                            constant: 24),
            selectionCategoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,
                                                                constant: 16),
            selectionCategoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                                 constant: -16),
            selectionCategoryTableView.bottomAnchor.constraint(equalTo: createCategoryButton.topAnchor)
        ])
    }
    
    private func setupStabView() {
        view.addSubview(conteinerStabView)
        [imageViewStab, lableTextStab].forEach {
            conteinerStabView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
        }
        
        NSLayoutConstraint.activate([
            conteinerStabView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            conteinerStabView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            imageViewStab.centerYAnchor.constraint(equalTo: conteinerStabView.centerYAnchor),
            imageViewStab.centerXAnchor.constraint(equalTo: conteinerStabView.centerXAnchor),
            
            lableTextStab.widthAnchor.constraint(equalToConstant: 200),
            lableTextStab.centerXAnchor.constraint(equalTo: conteinerStabView.centerXAnchor),
            lableTextStab.topAnchor.constraint(equalTo: imageViewStab.bottomAnchor,
                                               constant: 10)
        ])
    }
}

//MARK: - UITableViewDataSource
extension SelectCategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        handler.resultTypeHandlerGetValue(viewModel.сategoryExcludingFixed(),
                                          vc: self)?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(CustomTableViewCell.self)")
                as? CustomTableViewCell,
              let isSelected = handler.resultTypeHandlerGetValue(viewModel.isCategorySelected(at: indexPath.row),
                                                                 vc: self),
              let text = handler.resultTypeHandlerGetValue(viewModel.createNameCategory(at: indexPath.row),
                                                           vc: self),
              let category = handler.resultTypeHandlerGetValue(viewModel.сategoryExcludingFixed(),
                                                               vc: self)
        else { return UITableViewCell() }
        cell.showSelectedImage(flag: isSelected)
        let model = CustomCellModel(text: text, color: .backgroundNight)
        cell.config(model: model)
        
        if category.count > ConstantsCreateCatVc.one {
            cell.separatorInset = ConstantsCreateCatVc.insertSeparatorTableView
        }
        
        if indexPath.row == .zero && category.count == ConstantsCreateCatVc.one {
            cell.setupCornerRadius(cornerRadius: ConstantsCreateCatVc.cornerRadius,
                                   maskedCorners: nil)
            cell.separatorInset = UIEdgeInsets(top: .zero,
                                               left: view.bounds.width,
                                               bottom: .zero,
                                               right: .zero)
        }
        
        if indexPath.row == .zero && category.count > ConstantsCreateCatVc.one {
            cell.setupCornerRadius(cornerRadius: ConstantsCreateCatVc.cornerRadius,
                                   maskedCorners: [.layerMaxXMinYCorner,
                                                   .layerMinXMinYCorner])
        }
        
        if indexPath.row == category.count - ConstantsCreateCatVc.one &&
            category.count > ConstantsCreateCatVc.one {
            cell.setupCornerRadius(cornerRadius: ConstantsCreateCatVc.cornerRadius,
                                   maskedCorners: [.layerMinXMaxYCorner,
                                                   .layerMaxXMaxYCorner])
            cell.separatorInset = UIEdgeInsets(top: .zero,
                                               left: view.bounds.width,
                                               bottom: .zero,
                                               right: .zero)
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension SelectCategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell,
              let delegate
        else { return }
        cell.showSelectedImage(flag: false)
        handler.resultTypeHandler(viewModel.selectСategory(at: indexPath.row),
                                  vc: self) {}
        handler.resultTypeHandler(viewModel.createNameCategory(at: indexPath.row),
                                  vc: self) { [weak self] cat in
            guard let self else { return }
            delegate.categoriesViewController(vc: self, nameCategory: cat)
        }
    }
    
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(actionProvider:  { [weak self] _ in
            guard let self,
                  let category = self.handler.resultTypeHandlerGetValue(self.viewModel.сategoryExcludingFixed(),
                                                                   vc: self)?[indexPath.row]
            else { return UIMenu()}
            return UIMenu(children: [
                self.editAction(text: Translate.textEdit,
                           category: category),
                self.deleteAction(text: Translate.textDelete,
                             category: category,
                             index: indexPath.row,
                             trackers: category.arrayTrackers)
            ])
        })
    }
}

//MARK: - NewCategoriViewControllerDelegate
extension SelectCategoriesViewController: NewCategoriViewControllerDelegate {
    func didNewCategoryName(_ vc: UIViewController, nameCategory: String) {
        guard let category = handler.resultTypeHandlerGetValue(viewModel.getCategory(),
                                                               vc: self)
        else { return }
        let nameFirstUppercased = nameCategory.lowercased().firstUppercased
        if let _ = category.filter({ $0.nameCategory == nameFirstUppercased }).first {
            return
        }
        if nameFirstUppercased == Fixed.fixedRu.rawValue ||
            nameFirstUppercased == Fixed.fixedEng.rawValue {
            return
        }
        handler.resultTypeHandler(viewModel.addCategory(nameCategory: nameFirstUppercased),
                                  vc: self) {}
    }
}

//MARK: - UpdateCategoriViewControllerDelegate
extension SelectCategoriesViewController: UpdateCategoriViewControllerDelegate {
    func didUpdateCategoryName(_ vc: UIViewController,
                               newNameCategory: String,
                               oldNameCategory: String) {
        handler.resultTypeHandler(viewModel.updateNameCategory(newNameCategory: newNameCategory,
                                                               oldNameCaetegory: oldNameCategory),
                                  vc: self) {}
    }
}
