import Foundation
import UIKit

final class TrackerCreationViewController: UIViewController, TrackerCreationDelegate {
    
    private var privichkaViewController = PrivichkaViewController()
    
    weak var delegate: ReloadDataDelegate?
    
    private var viewLabel = UILabel()
    private var privichkaButton = UIButton()
    private var privichkaLabel = UILabel()
    private var sobitieButton = UIButton()
    private var sobitieLabel = UILabel()
    private var buttonStack = UIStackView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        privichkaViewController.delegate = self
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
        configurePrivichkaButton()
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
    
    private func configurePrivichkaButton() {
        
        buttonStack.addArrangedSubview(privichkaButton)
        privichkaButton.translatesAutoresizingMaskIntoConstraints = false
        privichkaButton.backgroundColor = .black
        privichkaButton.layer.cornerRadius = 16
        NSLayoutConstraint.activate([
            privichkaButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        configurePrivichkaLabel()
        privichkaButton.addTarget(self, action: #selector(privichkaButtonTapped), for: .touchUpInside)

        
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
    
    private func configurePrivichkaLabel() {
        privichkaButton.addSubview(privichkaLabel)
        privichkaLabel.translatesAutoresizingMaskIntoConstraints = false
        privichkaLabel.text = "Привычка"
        privichkaLabel.font = .systemFont(ofSize: 16)
        privichkaLabel.textColor = .white
        NSLayoutConstraint.activate([
            privichkaLabel.centerXAnchor.constraint(equalTo: privichkaButton.centerXAnchor),
            privichkaLabel.centerYAnchor.constraint(equalTo: privichkaButton.centerYAnchor)
        ])
    }
    
    
    @objc func sobitieButtonTapped() {
        privichkaViewController.isPrivichka = false
        self.present(privichkaViewController, animated: true)
    }
    
    @objc func privichkaButtonTapped() {
        privichkaViewController.isPrivichka = true
        self.present(privichkaViewController, animated: true)
    }
    
    func sendTracker(tracker: Tracker, categoryName: String) {
        delegate?.reloadData(tracker: tracker, categoryName: categoryName)
        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
    }

    
}
