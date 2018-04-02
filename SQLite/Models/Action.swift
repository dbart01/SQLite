//
//  Action.swift
//  SQLite
//
//  Created by Dima Bart on 2018-03-29.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

public enum Action: RawRepresentable {
    
    case insert
    case update
    case delete
    
    public typealias RawValue = Int32
    
    public var rawValue: RawValue {
        switch self {
        case .insert: return SQLITE_INSERT
        case .update: return SQLITE_UPDATE
        case .delete: return SQLITE_DELETE
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case type(of: self).insert.rawValue: self = .insert
        case type(of: self).update.rawValue: self = .update
        case type(of: self).delete.rawValue: self = .delete
        default:
            return nil
        }
    }
}

extension Int32 {
    var action: Action {
        return Action(rawValue: self)!
    }
}
