//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Maksim Zimens on 14.10.2023.
//

import Foundation
import UIKit

final class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        tabBar.layer.borderWidth = 1
        tabBar.layer.borderColor = UIColor.lightGray.cgColor
        tabBar.clipsToBounds = true
        let trackersViewController = TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        
        let trackers = NSLocalizedString("trackers", comment: "")
        let statistics = NSLocalizedString("statistics", comment: "")
        
        trackersViewController.tabBarItem = UITabBarItem(title: trackers, image: UIImage(named: "TrackersTabBar"), tag: 0)
        statisticsViewController.tabBarItem = UITabBarItem(title: statistics, image: UIImage(named: "RabbitTabBar"), tag: 0)
        
        self.viewControllers = [trackersViewController, statisticsViewController]
    }
}
