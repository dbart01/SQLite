//
//  SQLite3.Location.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-20.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension SQLite3 {
    public enum Location: Equatable {
        
        case disk(URL)
        case memory
        case temporary
        
        var path: String {
            switch self {
            case .disk(let url): return url.path
            case .memory:        return ":memory:"
            case .temporary:     return ""
            }
        }
    }
}

extension SQLite3.Location {
    public static func ==(lhs: SQLite3.Location, rhs: SQLite3.Location) -> Bool {
        switch (lhs, rhs) {
        case (.disk(let lv), .disk(let rv)) where lv == rv:
            return true
        case (.memory, .memory):
            return true
        case (.temporary, .temporary):
            return true
        default:
            return false
        }
    }
}
