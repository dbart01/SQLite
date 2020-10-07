//
//  SQLite.Location.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-20.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension SQLite {
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
