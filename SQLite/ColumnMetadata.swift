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

extension ValueType {
    public static func ==(lhs: ValueType, rhs: ValueType) -> Bool {
        switch (lhs, rhs) {
        case (.integer, .integer): return true
        case (.double, .double):   return true
        case (.text, .text):       return true
        case (.blob, .blob):       return true
        default:
            return false
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

extension CollationSequence {
    public static func ==(lhs: CollationSequence, rhs: CollationSequence) -> Bool {
        switch (lhs, rhs) {
        case (.binary, .binary): return true
        case (.nocase, .nocase): return true
        case (.rtrim, .rtrim):   return true
        case (.custom(let lv), .custom(let rv)) where lv == rv:
            return true
        default:
            return false
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

extension ColumnMetadata {
    public static func ==(lhs: ColumnMetadata, rhs: ColumnMetadata) -> Bool {
        return lhs.type     == rhs.type &&
        lhs.collation       == rhs.collation &&
        lhs.isNotNull       == rhs.isNotNull &&
        lhs.isPrimaryKey    == rhs.isPrimaryKey &&
        lhs.isAutoIncrement == rhs.isAutoIncrement
    }
}
