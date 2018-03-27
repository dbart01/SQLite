//
//  Pragma.Encoding.swift
//  SQLite MacOS
//
//  Created by Dima Bart on 2018-03-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension Pragma {
    public enum Encoding: PragmaRepresentable {
        
        case utf8
        case utf16
        case utf16le
        case utf16be
        
        public typealias RawValue = String
        
        public var rawValue: RawValue {
            switch self {
            case .utf8:    return "UTF-8"
            case .utf16:   return "UTF-16"
            case .utf16le: return "UTF-16le"
            case .utf16be: return "UTF-16be"
            }
        }
        
        public init?(rawValue: RawValue) {
            switch rawValue {
            case Encoding.utf8.rawValue:    self = .utf8
            case Encoding.utf16.rawValue:   self = .utf16
            case Encoding.utf16le.rawValue: self = .utf16le
            case Encoding.utf16be.rawValue: self = .utf16be
            default:
                return nil
            }
        }
        
        public var sqlValue: String {
            return "'\(self.rawValue)'"
        }
    }
}
