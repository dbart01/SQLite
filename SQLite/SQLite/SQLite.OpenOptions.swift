//
//  SQLite.OpenOptions.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-20.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension SQLite {
    public struct OpenOptions: OptionSet {
        
        public static let readOnly     = OpenOptions(rawValue: SQLITE_OPEN_READONLY)
        public static let readWrite    = OpenOptions(rawValue: SQLITE_OPEN_READWRITE)
        public static let create       = OpenOptions(rawValue: SQLITE_OPEN_CREATE)
        public static let uri          = OpenOptions(rawValue: SQLITE_OPEN_URI)
        public static let memory       = OpenOptions(rawValue: SQLITE_OPEN_MEMORY)
        public static let noMutex      = OpenOptions(rawValue: SQLITE_OPEN_NOMUTEX)
        public static let fullMutex    = OpenOptions(rawValue: SQLITE_OPEN_FULLMUTEX)
        public static let sharedCache  = OpenOptions(rawValue: SQLITE_OPEN_SHAREDCACHE)
        public static let privateCache = OpenOptions(rawValue: SQLITE_OPEN_PRIVATECACHE)
        
        public let rawValue: Int32
        
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
    }
}
