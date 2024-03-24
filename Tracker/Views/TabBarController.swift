//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Maksim Zimens on 14.10.2023.
//

import UIKit

//MARK: - TabBarController
final class TabBarController: UITabBarController {
    private struct ConstantsTabBar {
        static let tabBarImageTrecker =  "tabBarTracker"
        static let tabBarImageStatistic = "tabBarStatistic"
        
        static let insertImage = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
    }
    
    private let colors = Colors()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.layer.borderWidth = 1
        tabBar.clipsToBounds = true
        let trackerViewController = TrackersViewController(viewModel: TrackerViewModel())
        let statisticsViewController = StatisticsViewController()
        
        let trackerNavigationController = UINavigationController(rootViewController: trackerViewController)
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        
        viewControllers = [
            generateViewController(vc: trackerNavigationController,
                                   imageName: ConstantsTabBar.tabBarImageTrecker,
                                   title: Translate.tabBarTitleTrecker,
                                   insert: ConstantsTabBar.insertImage),
            
            generateViewController(vc: statisticsNavigationController,
                                   imageName: ConstantsTabBar.tabBarImageStatistic,
                                   title: Translate.tabBarTitleStatistic,
                                   insert: ConstantsTabBar.insertImage)
        ]
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *),
           // Проверяем только изменение цветовой схемы
           traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if traitCollection.userInterfaceStyle == .dark {
                tabBar.layer.borderColor = UIColor.black.cgColor
            } else {
                tabBar.layer.borderColor = UIColor.grayDay.cgColor
            }
        }
    }
    
    deinit {
        AnalyticsService.reportEvent(field: MetricEvent(event: .close,
                                                        params: [EventAnalytics.screen.rawValue: Screen.Main.rawValue]))
    }
}

//MARK: - Setup
private extension TabBarController {
    func generateViewController(vc: UIViewController,
                                imageName: String,
                                title: String,
                                insert: UIEdgeInsets ) -> UIViewController {
        vc.tabBarItem.image = UIImage(named: imageName)
        vc.tabBarItem.title = title
        vc.tabBarItem.imageInsets = insert
        
        return vc
    }
}
