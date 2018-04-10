//
//  Function.ArgCount.swift
//  SQLite
//
//  Created by Dima Bart on 2018-04-05.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension Function {
    public enum ArgCount: Equatable {
        
        case infinite
        case none
        case finite(Int)
        
        var integerValue: Int {
            switch self {
            case .infinite:      return -1
            case .none:          return 0
            case .finite(let v): return v
            }
        }
    }
}
