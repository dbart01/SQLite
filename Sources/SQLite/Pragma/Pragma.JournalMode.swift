//
//  Pragma.JournalMode.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-27.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension Pragma {
    public enum JournalMode: PragmaRepresentable {
        
        case off
        case delete
        case truncate
        case persist
        case memory
        case wal
        
        public typealias RawValue = String
        
        public var rawValue: RawValue {
            switch self {
            case .off:      return "OFF"
            case .delete:   return "DELETE"
            case .truncate: return "TRUNCATE"
            case .persist:  return "PERSIST"
            case .memory:   return "MEMORY"
            case .wal:      return "WAL"
            }
        }
        
        public init?(rawValue: RawValue) {
            switch rawValue.uppercased() {
            case JournalMode.off.rawValue:      self = .off
            case JournalMode.delete.rawValue:   self = .delete
            case JournalMode.truncate.rawValue: self = .truncate
            case JournalMode.persist.rawValue:  self = .persist
            case JournalMode.memory.rawValue:   self = .memory
            case JournalMode.wal.rawValue:      self = .wal
            default:
                return nil
            }
        }
        
        public var sqlValue: String {
            return "\(self.rawValue)"
        }
    }
}
