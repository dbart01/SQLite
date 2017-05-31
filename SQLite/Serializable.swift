//
//  Serializable.swift
//  SQLite
//
//  Created by Dima Bart on 2017-05-30.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

public protocol Serializable {
    var value: Value { get }
}

extension String: Serializable {
    public var value: Value {
        return .string(self)
    }
}

extension Int: Serializable {
    public var value: Value {
        return .integer(self)
    }
}

extension Double: Serializable {
    public var value: Value {
        return .double(self)
    }
}

extension Data: Serializable {
    public var value: Value {
        return .blob(self)
    }
}
