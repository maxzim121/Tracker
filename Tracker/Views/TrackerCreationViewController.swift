import Foundation
import UIKit

final class TrackerCreationViewController: UIViewController, TrackerCreationDelegate {
    
    private var habbitViewController = HabbitViewController()
    
    weak var delegate: ReloadDataDelegate?
    
    private var viewLabel = UILabel()
    private var habbitButton = UIButton()
    private var habbitLabel = UILabel()
    private var sobitieButton = UIButton()
    private var sobitieLabel = UILabel()
    private var buttonStack = UIStackView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        habbitViewController.delegate = self
        configureViewLabel()
        configureStackView()
    }
    
    private func configureStackView() {
        
        view.addSubview(buttonStack)
        buttonStack.axis = .vertical
        buttonStack.spacing = 16
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStack.heightAnchor.constraint(equalToConstant: 136)
        ])
        configureHabbitButton()
        configureSobitieButton()
    }
    
    private func configureViewLabel() {
        viewLabel.text = "Создание трекера"
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
    
    private func configureSobitieButton() {
        
        buttonStack.addArrangedSubview(sobitieButton)
        sobitieButton.translatesAutoresizingMaskIntoConstraints = false
        sobitieButton.backgroundColor = .black
        sobitieButton.layer.cornerRadius = 16
        NSLayoutConstraint.activate([
            sobitieButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        configureSobitieLabel()
        sobitieButton.addTarget(self, action: #selector(sobitieButtonTapped), for: .touchUpInside)
        
        
    }
    
    private func configureHabbitButton() {
        
        buttonStack.addArrangedSubview(habbitButton)
        habbitButton.translatesAutoresizingMaskIntoConstraints = false
        habbitButton.backgroundColor = .black
        habbitButton.layer.cornerRadius = 16
        NSLayoutConstraint.activate([
            habbitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        configureHabbitLabel()
        habbitButton.addTarget(self, action: #selector(habbitButtonTapped), for: .touchUpInside)

        
    }
    
    private func configureSobitieLabel() {
        sobitieButton.addSubview(sobitieLabel)
        sobitieLabel.translatesAutoresizingMaskIntoConstraints = false
        sobitieLabel.text = "Нерегулярное событие"
        sobitieLabel.font = .systemFont(ofSize: 16)
        sobitieLabel.textColor = .white
        NSLayoutConstraint.activate([
            sobitieLabel.centerXAnchor.constraint(equalTo: sobitieButton.centerXAnchor),
            sobitieLabel.centerYAnchor.constraint(equalTo: sobitieButton.centerYAnchor)
        ])
    }
    
    private func configureHabbitLabel() {
        habbitButton.addSubview(habbitLabel)
        habbitLabel.translatesAutoresizingMaskIntoConstraints = false
        habbitLabel.text = "Привычка"
        habbitLabel.font = .systemFont(ofSize: 16)
        habbitLabel.textColor = .white
        NSLayoutConstraint.activate([
            habbitLabel.centerXAnchor.constraint(equalTo: habbitButton.centerXAnchor),
            habbitLabel.centerYAnchor.constraint(equalTo: habbitButton.centerYAnchor)
        ])
    }
    
    
    @objc func sobitieButtonTapped() {
        habbitViewController.isHabbit = false
        self.present(habbitViewController, animated: true)
    }
    
    @objc func habbitButtonTapped() {
        habbitViewController.isHabbit = true
        self.present(habbitViewController, animated: true)
    }
    
    func sendTracker(tracker: Tracker, categoryName: String) {
        delegate?.reloadData(tracker: tracker, categoryName: categoryName)
        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
    }

    
}
