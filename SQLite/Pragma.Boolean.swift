//
//  Pragma.Boolean.swift
//  SQLite
//
//  Created by Dima Bart on 2018-03-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension Pragma {
    public enum Boolean: PragmaRepresentable {
        
        case off
        case on
        
        public typealias RawValue = Int
        
        public var rawValue: Int {
            switch self {
            case .off: return 0
            case .on:  return 1
            }
        }
        
        public init?(rawValue: RawValue) {
            switch rawValue {
            case Boolean.off.rawValue: self = .off
            case Boolean.on.rawValue:  self = .on
            default:
                return nil
            }
        }
        
        public var sqlValue: String {
            switch self {
            case .on:  return "ON"
            case .off: return "OFF"
            }
        }
    }
}
