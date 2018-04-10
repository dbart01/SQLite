//
//  OptionalProtocol.swift
//  SQLite
//
//  Created by Dima Bart on 2018-04-05.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

protocol OptionalProtocol {
    var hasSome: Bool { get }
    var some:    Any  { get }
}

// TODO: Write tests
extension Optional: OptionalProtocol {
    
    var hasSome: Bool {
        switch self {
        case .some: return true
        case .none: return false
        }
    }
    
    var some: Any {
        switch self {
        case .some(let value):
            return value
        case .none:
            return self!
        }
    }
}
