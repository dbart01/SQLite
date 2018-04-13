//
//  ColumnMetadata.swift
//  SQLite
//
//  Created by Dima Bart on 2017-06-06.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

public enum ValueType: Equatable {
    case integer
    case double
    case text
    case blob
    
    public init?(type: String) {
        switch type {
        case "INTEGER": self = .integer
        case "REAL":    self = .double
        case "TEXT":    self = .text
        case "BLOB":    self = .blob
        default:
            return nil
        }
    }
}

public enum CollationSequence: Equatable {
    case binary
    case nocase
    case rtrim
    case custom(String)
    
    public init(sequence: String) {
        switch sequence {
        case "BINARY": self = .binary
        case "NOCASE": self = .nocase
        case "RTRIM":  self = .rtrim
        default:       self = .custom(sequence)
        }
    }
}

public struct ColumnMetadata: Equatable {
    public let type:            ValueType
    public let collation:       CollationSequence
    public let isNotNull:       Bool
    public let isPrimaryKey:    Bool
    public let isAutoIncrement: Bool
    
    public init(type: String, collation: String, isNotNull: Bool, isPrimaryKey: Bool, isAutoIncrement: Bool) {
        self.type            = ValueType(type: type)!
        self.collation       = CollationSequence(sequence: collation)
        self.isNotNull       = isNotNull
        self.isPrimaryKey    = isPrimaryKey
        self.isAutoIncrement = isAutoIncrement
    }
}
