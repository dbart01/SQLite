//
//  UnsafePointer+String.swift
//  SQLite
//
//  Created by Dima Bart on 2017-06-06.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

extension UnsafePointer where Pointee == Int8 {
    var string: String {
        return String(cString: self)
    }
}

extension UnsafeMutablePointer where Pointee == Int8 {
    var string: String {
        return String(cString: self)
    }
}

extension UnsafePointer where Pointee == UInt8 {
    var string: String {
        return String(cString: self)
    }
}
