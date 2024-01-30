//
//  OnboardingViewCOntroller.swift
//  Tracker
//
//  Created by Maksim Zimens on 29.01.2024.
//

import Foundation
import UIKit


final class OnboardingViewController: UIViewController {
    
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    private lazy var onboardingLableView: UILabel = {
        let onboardingLableView = UILabel()
        onboardingLableView.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        onboardingLableView.textColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        onboardingLableView.textAlignment = .center
        onboardingLableView.numberOfLines = 2
        
        return onboardingLableView
    }()
    
    private lazy var startButton: UIButton = {
        let startButton = UIButton()
        startButton.setTitle("Вот это технологии!", for: .normal)
        startButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        startButton.titleLabel?.textColor = .white
        startButton.addTarget(self, action: #selector(showViewController), for: .touchUpInside)
        
        return startButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupSubViews()
    }
}

extension OnboardingViewController {
    //MARK: - SetupUI
    private func setupSubViews() {
        [imageView, onboardingLableView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
        }
        setupContentImageView()
        setupStartButton()
        setupOnboardingLableView()
    }
    
    private func setupContentImageView() {
        NSLayoutConstraint.activate ([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: -1),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 1),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 1),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -1)
        ])
    }
    
    private func setupOnboardingLableView() {
        NSLayoutConstraint.activate([
            onboardingLableView.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -160),
            onboardingLableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            onboardingLableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupStartButton() {
        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.backgroundColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        startButton.layer.cornerRadius = 16
        startButton.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            startButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    //MARK: - Configure
    func config(model: Onboarding) {
        guard let image = UIImage(named: model.imageName) else { return }
        imageView.image = image
        onboardingLableView.text = model.textLable
    }
    
    @objc
    private func showViewController() {
        guard let window = UIApplication.shared.windows.first else { return }
        let vc = TabBarViewController()
        window.rootViewController = vc
    }
}
