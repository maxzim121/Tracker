//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Maksim Zimens on 30.01.2024.
//

import Foundation
import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func didNewCategoriName(_ vc: UIViewController, nameCategori: String)
}

class NewCategoryViewController: UIViewController {
    private struct ConstantsNewCatVc {
        static let newcategoriLabelText = "Новая категория"
        static let buttonName = "Готово"
        static let placeholderTextField = "Введите название категории"
        
        static let cornerRadius = CGFloat(16)
        static let leftIndentTextField = CGFloat(12)
        static let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let textFieldFont = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
    private var nameCategori: String = "" {
        didSet {
            chengeHiddenButton(flag: nameCategori.isEmpty)
        }
    }
    
    weak var delegate: NewCategoryViewControllerDelegate?
    
    private lazy var newCategoriLabel: UILabel = {
        let newCategoriLabel = UILabel()
        newCategoriLabel.text = ConstantsNewCatVc.newcategoriLabelText
        newCategoriLabel.textColor = .black
        newCategoriLabel.font = ConstantsNewCatVc.font
        newCategoriLabel.textAlignment = .center
        newCategoriLabel.backgroundColor = .clear
        
        return newCategoriLabel
    }()
    
    private lazy var readyButton: UIButton = {
        let readyButton = UIButton()
        readyButton.setTitle(ConstantsNewCatVc.buttonName, for: .normal)
        readyButton.titleLabel?.textColor = UIColor.white
        readyButton.isEnabled = false
        readyButton.backgroundColor = UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
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
        createNameTextField.placeholder = ConstantsNewCatVc.placeholderTextField
        createNameTextField.font = ConstantsNewCatVc.textFieldFont
        createNameTextField.indent(size: ConstantsNewCatVc.leftIndentTextField)
        createNameTextField.backgroundColor = UIColor(red: 0.902, green: 0.91, blue: 0.922, alpha: 0.3)
        createNameTextField.layer.cornerRadius = ConstantsNewCatVc.cornerRadius
        createNameTextField.layer.masksToBounds = true
        createNameTextField.clearButtonMode = .whileEditing
        
        return createNameTextField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        view.backgroundColor = .white
        setupUIElement()
    }
}

private extension NewCategoryViewController {
    //MARK: - Обработка событий
    @objc
    func didTapNewСategoriButton() {
        delegate?.didNewCategoriName(self, nameCategori: nameCategori)
        dismiss(animated: true)
    }
    
    @objc
    private func hideKeyboard() {
        view.endEditing(true)
    }
    
    func chengeHiddenButton(flag: Bool) {
        readyButton.isEnabled = !flag
        readyButton.backgroundColor = !flag ? UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1) : UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1)
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
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func setupCategoriLabel() {
        view.addSubview(newCategoriLabel)
        newCategoriLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            newCategoriLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            newCategoriLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setupCreateNameTextField() {
        view.addSubview(createNameTextField)
        createNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            createNameTextField.topAnchor.constraint(equalTo: newCategoriLabel.bottomAnchor, constant: 24),
            createNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createNameTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
}

//MARK: - UITextFieldDelegate
extension NewCategoryViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        nameCategori = text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        createNameTextField.resignFirstResponder()
        return true
    }
}
