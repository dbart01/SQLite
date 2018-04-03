//
//  Pragma.CacheSize.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension Pragma {
    public enum CacheSize: PragmaRepresentable, Equatable {
        
        case pages(UInt)
        case kilobytes(UInt)
        
        public typealias RawValue = Int
        
        public var rawValue: RawValue {
            switch self {
            case .pages(let value):     return Int(value)
            case .kilobytes(let value): return -Int(value)
            }
        }
        
        public init?(rawValue: RawValue) {
            let value = UInt(abs(rawValue))
            if rawValue >= 0 {
                self = .pages(value)
            } else {
                self = .kilobytes(value)
            }
        }
        
        public var sqlValue: String {
            return "\(self.rawValue)"
        }
    }
}
