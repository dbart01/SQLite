//
//  Encoding.swift
//  SQLite
//
//  Created by Dima Bart on 2018-04-05.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

public enum Encoding: Equatable, RawRepresentable {
    case utf8
    case utf16
    case utf16le
    case utf16be
    
    public typealias RawValue = Int32
    
    public var rawValue: RawValue {
        switch self {
        case .utf8:    return SQLITE_UTF8
        case .utf16:   return SQLITE_UTF16
        case .utf16le: return SQLITE_UTF16LE
        case .utf16be: return SQLITE_UTF16BE
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
}
