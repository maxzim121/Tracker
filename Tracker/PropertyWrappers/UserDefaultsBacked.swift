//
//  UserDefaultsBakced.swift
//  Tracker
//
//  Created by Maksim Zimens on 29.01.2024.
//

import Foundation

@propertyWrapper
struct UserDefaultsBacked<Value> {
    let key: String
    var storage: UserDefaults = .standard
    var wrappedValue: Value? {
        get {
            storage.value(forKey:key) as? Value
        }
        set {
            storage.setValue(newValue, forKey: key)
        }
    }
    
}
