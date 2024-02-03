//
//  Colors.swift
//  Tracker
//
//  Created by Maksim Zimens on 03.02.2024.
//

import UIKit

final class Colors {
    lazy var viewBackground = UIColor.systemBackground
    
    lazy var buttonDisabledColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.blackDay
        } else {
            return UIColor.whiteDay
        }
    }
    
    lazy var buttonEventColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.blackDay
        } else {
            return UIColor.whiteDay
        }
    }
    
    lazy var whiteBlackItemColor = UIColor { (traits: UITraitCollection) -> UIColor in
        if traits.userInterfaceStyle == .light {
            return UIColor.black
        } else {
            return UIColor.white
        }
    }
}
