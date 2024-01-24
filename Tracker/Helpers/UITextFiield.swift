//
//  UITextFiield.swift
//  Tracker
//
//  Created by Maksim Zimens on 20.01.2024.
//

import UIKit

import UIKit

extension UITextField {
    func indent(size:CGFloat) {
        self.leftView = UIView(frame: CGRect(x: self.frame.minX, y: self.frame.minY, width: size, height: self.frame.height))
        self.leftViewMode = .always
    }
}
