//
//  HandlerResultType.swift
//  Tracker
//
//  Created by Maksim Zimens on 03.02.2024.
//

import UIKit

final class HandlerResultType {
    func resultTypeHandler<Value>(_ listCategory: Result<Value,
                                  Error>, vc: UIViewController,
                                  handler: (Value) -> Void) {
        switch listCategory {
        case .success(let newValue):
            handler(newValue)
        case .failure(let error):
            showMessageErrorAlert(message: error.localizedDescription,
                                  viewController: vc)
        }
    }
    
    func resultTypeHandlerGetValue<Value>(_ value: Result<Value, Error>,
                                          vc: UIViewController) -> Value? {
        switch value {
        case .success(let newValue):
            return newValue
        case .failure(let error):
            showMessageErrorAlert(message: error.localizedDescription,
                                  viewController: vc)
            return nil
        }
    }
    
    private func showMessageErrorAlert(message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: .alert)
        viewController.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            alert.dismiss(animated: true)
        })
    }
}
