//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Maksim Zimens on 30.01.2024.
//

import Foundation
import UIKit

protocol CreateCategoriesViewControllerDelegate: AnyObject {
    func createCategoriesViewController(vc: UIViewController, nameCategory: String)
}

//MARK: - CreateCategoriesViewController
final class CategoryViewController: UIViewController {
    
    weak var delegate: CreateCategoriesViewControllerDelegate?
    
    private var viewModel: CategoryViewModel?
    
    private lazy var categoriLabel: UILabel = {
        let categoriLabel = UILabel()
        categoriLabel.text = "Категория"
        categoriLabel.textColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        categoriLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        categoriLabel.textAlignment = .center
        categoriLabel.backgroundColor = .clear
        
        return categoriLabel
    }()
    
    private lazy var imageViewStab: UIImageView = {
        let imageViewStab = UIImageView()
        let image = UIImage(named: "StarGray")
        imageViewStab.image = image
        
        return imageViewStab
    }()
    
    private lazy var lableTextStab: UILabel = {
        let lableTextStab = UILabel()
        lableTextStab.text = "Привычки и события можно объединить по смыслу"
        lableTextStab.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        lableTextStab.numberOfLines = 2
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
    
    private lazy var selectionCategoriTableView: UITableView = {
        let selectionCategoriTableView = UITableView()
        selectionCategoriTableView.dataSource = self
        selectionCategoriTableView.delegate = self
        selectionCategoriTableView.backgroundColor = .clear
        selectionCategoriTableView.separatorStyle = .singleLine
        selectionCategoriTableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "\(CategoryTableViewCell.self)")
        selectionCategoriTableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        return selectionCategoriTableView
    }()
    
    private lazy var createCategoriButton: UIButton = {
        let createCategoriButton = UIButton()
        createCategoriButton.setTitle("Добавить категорию", for: .normal)
        createCategoriButton.titleLabel?.textColor = .white
        createCategoriButton.backgroundColor = .black
        createCategoriButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createCategoriButton.layer.cornerRadius = 16
        createCategoriButton.layer.masksToBounds = true
        createCategoriButton.translatesAutoresizingMaskIntoConstraints = false
        
        createCategoriButton.addTarget(self, action: #selector(didTapСategoriButton), for: .touchUpInside)
        
        return createCategoriButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel else { return }
        bind()
        view.backgroundColor = .white
        setupUIElement()
        showStabView(flag: !viewModel.category.isEmpty)
        selectionCategoriTableView.rowHeight = 75
        
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
}

extension CategoryViewController {
    func config(viewModel: CategoryViewModel?) {
        self.viewModel = viewModel
    }
    
    //MARK: - обработка событий
    @objc
    private func didTapСategoriButton() {
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.delegate = self
        newCategoryVC.modalPresentationStyle = .formSheet
        present(newCategoryVC, animated: true)
    }
    
    // метод показа/скрытия заглушки
    private func showStabView(flag: Bool) {
        conteinerStabView.isHidden = flag
    }
    
    private func bind() {
        viewModel?.$category.bind { [weak self] _ in
            guard let self else { return }
            guard let viewModel = self.viewModel else { return }
            self.showStabView(flag: !viewModel.category.isEmpty)
            self.selectionCategoriTableView.reloadData()
        }
    }
        
    //MARK: - SetupUI
    private func setupUIElement() {
        setupCategoriButton()
        setupCategoriLabel()
        setupTableView()
        setupStabView()
    }
    
    private func setupCategoriButton() {
        view.addSubview(createCategoriButton)
        
        NSLayoutConstraint.activate([
            createCategoriButton.heightAnchor.constraint(equalToConstant: 60),
            createCategoriButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            createCategoriButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createCategoriButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupCategoriLabel() {
        view.addSubview(categoriLabel)
        categoriLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoriLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoriLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTableView() {
        view.addSubview(selectionCategoriTableView)
        selectionCategoriTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            selectionCategoriTableView.topAnchor.constraint(equalTo: categoriLabel.bottomAnchor, constant: 24),
            selectionCategoriTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectionCategoriTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -16),
            selectionCategoriTableView.bottomAnchor.constraint(equalTo: createCategoriButton.topAnchor)
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
            lableTextStab.topAnchor.constraint(equalTo: imageViewStab.bottomAnchor, constant: 10)
        ])
    }
}

//MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel else { return 0 }
        return viewModel.category.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(CategoryTableViewCell.self)") as? CategoryTableViewCell,
              let viewModel
        else { return UITableViewCell() }
        let isSelected = viewModel.isCategorySelected(at: indexPath.row)
        let text = viewModel.createNameCategory(at: indexPath.row)
        cell.showSelectedImage(flag: isSelected)
        let model = CategoryCellModel(text: text, color: UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3))
        cell.config(model: model)
        
        if viewModel.category.count > 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        }
        
        if indexPath.row == viewModel.category.count - 1 {
            cell.setupCornerRadius(cornerRadius: 16,
                                   maskedCorners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
            cell.separatorInset = UIEdgeInsets(top: 0, left: view.bounds.width, bottom: 0, right: 0)
        }
        
        if indexPath.row == 0 {
            cell.setupCornerRadius(cornerRadius: 16,
                                   maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell,
              let delegate,
              let viewModel
        else { return }
        cell.showSelectedImage(flag: false)
        viewModel.selectСategory(at: indexPath.row)
        let nameCategory = viewModel.createNameCategory(at: indexPath.row)
        delegate.createCategoriesViewController(vc: self, nameCategory: nameCategory)
    }
}

//MARK: - NewCategoriViewControllerDelegate
extension CategoryViewController: NewCategoryViewControllerDelegate {
    func didNewCategoriName(_ vc: UIViewController, nameCategori: String) {
        guard let viewModel else { return }
        let nameFirstUppercased = nameCategori.lowercased()
        if viewModel.category.filter({ $0.categoryName.lowercased() == nameFirstUppercased }).count > 0 {
            return
        }
        
        try? viewModel.addCategory(nameCategory: nameCategori)
    }
}
