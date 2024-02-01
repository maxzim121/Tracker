//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Maksim Zimens on 29.01.2024.
//

import Foundation
import UIKit

final class OnboardingPageViewController: UIPageViewController {    
    private var currentIndex: Int = 1
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 2
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1)
        pageControl.pageIndicatorTintColor = UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1).withAlphaComponent(0.3)
        
        return pageControl
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        setupPageControl()
    }
}

private extension OnboardingPageViewController {
    func setupPageControl() {
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134)
        ])
    }
}

//MARK: - UIPageViewControllerDataSource
extension OnboardingPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let twoViewControllers = OnboardingViewController()
        let textLableTwoVC = NSLocalizedString("textLableTwoVC", comment: "")
        let onboardingModelTwoVC = Onboarding(imageName: "secondPage",
                                              textLable: textLableTwoVC)
        twoViewControllers.config(model: onboardingModelTwoVC)
        if currentIndex == 2 {
            return nil
        }
        currentIndex += 1
        
        return twoViewControllers
    }
}

//MARK: - UIPageViewControllerDelegate
extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        pageControl.currentPage = pageControl.currentPage == 1 ? 0 : 1
    }
}
