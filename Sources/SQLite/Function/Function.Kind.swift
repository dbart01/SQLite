//
//  Function.Kind.swift
//  SQLite
//
//  Created by Dima Bart on 2018-04-05.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension Function {
    public enum Kind: Equatable {
        case scalar
        case aggregate
    }
}
