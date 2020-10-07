//
//  SQLite.Checkpoint.swift
//  SQLite MacOS
//
//  Created by Dima Bart on 2018-04-02.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation
import sqlite3

extension SQLite {
    public enum Checkpoint: RawRepresentable {
        
        case passive
        case full
        case restart
        case truncate
        
        public typealias RawValue = Int32
        
        public var rawValue: RawValue {
            switch self {
            case .passive:  return SQLITE_CHECKPOINT_PASSIVE
            case .full:     return SQLITE_CHECKPOINT_FULL
            case .restart:  return SQLITE_CHECKPOINT_RESTART
            case .truncate: return SQLITE_CHECKPOINT_TRUNCATE
            }
        }
        
        public init?(rawValue: RawValue) {
            switch rawValue {
            case type(of: self).passive.rawValue:  self = .passive
            case type(of: self).full.rawValue:     self = .full
            case type(of: self).restart.rawValue:  self = .restart
            case type(of: self).truncate.rawValue: self = .truncate
            default:
                return nil
            }
        }
    }
}
