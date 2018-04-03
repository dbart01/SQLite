//
//  Initialize.swift
//  SQLite
//
//  Created by Dima Bart on 2018-04-03.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

internal func initialize<T>(_ type: T.Type, block: (UnsafeMutablePointer<T?>) -> Status) throws -> T {
    var reference: T?
    let status = withUnsafeMutablePointer(to: &reference) {
        return block($0)
    }
    
    guard status == .ok else {
        throw status
    }
    
    return reference!
}
