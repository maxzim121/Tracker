//
//  Observerable.swift
//  Tracker
//
//  Created by Maksim Zimens on 30.01.2024.
//

import Foundation
@propertyWrapper
final class Observable<Value> {
    private var onChange: ((Value) -> Void)? = nil
    
    var wrappedValue: Value {
        didSet {
            onChange?(wrappedValue)
        }
    }
    
    var projectedValue: Observable<Value> {
        self
    }
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    func bind(action: @escaping (Value) -> Void) {
        self.onChange = action
    }
}
