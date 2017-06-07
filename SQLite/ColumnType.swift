//
//  ColumnType.swift
//  SQLite
//
//  Created by Dima Bart on 2017-06-07.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

public enum ColumnType {
    case integer
    case float
    case text
    case blob
    case null
    
    public init?(type: Int32) {
        switch type {
        case SQLITE_INTEGER: self = .integer
        case SQLITE_FLOAT:   self = .float
        case SQLITE_TEXT:    self = .text
        case SQLITE_BLOB:    self = .blob
        case SQLITE_NULL:    self = .null
        default:
            return nil
        }
    }
}

extension Int32 {
    var columnType: ColumnType? {
        return ColumnType(type: self)
    }
}
