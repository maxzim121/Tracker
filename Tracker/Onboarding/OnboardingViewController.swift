import UIKit

//MARK: - OnboardingViewController
final class OnboardingViewController: UIViewController {
    private struct ConstantsOnboardingViewController {
        static let cornerRadiusButton = CGFloat(16)
        static let fontTextLable = UIFont.systemFont(ofSize: 32, weight: .bold)
        static let fontTextButton = UIFont.systemFont(ofSize: 16, weight: .medium)
        static let numberOfLineTextLable = 2
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        
        return imageView
    }()
    
    private lazy var onboardingLableView: UILabel = {
        let onboardingLableView = UILabel()
        onboardingLableView.font = ConstantsOnboardingViewController.fontTextLable
        onboardingLableView.textColor = .blackDay
        onboardingLableView.textAlignment = .center
        onboardingLableView.numberOfLines =  ConstantsOnboardingViewController.numberOfLineTextLable
        
        return onboardingLableView
    }()
    
    private lazy var startButton: UIButton = {
        let startButton = UIButton()
        startButton.setTitle(Translate.textButton, for: .normal)
        startButton.titleLabel?.font = ConstantsOnboardingViewController.fontTextButton
        startButton.titleLabel?.textColor = .whiteDay
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
        startButton.backgroundColor = .blackDay
        startButton.layer.cornerRadius = ConstantsOnboardingViewController.cornerRadiusButton
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
        let vc = TabBarController()
        window.rootViewController = vc
    }
}
