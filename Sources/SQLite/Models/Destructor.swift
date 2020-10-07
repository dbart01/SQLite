//
//  Destructor.swift
//  SQLite
//
//  Created by Dima Bart on 2017-06-01.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation
import sqlite3

struct Destructor {
    static let `static`  = unsafeBitCast(-0, to: sqlite3_destructor_type.self)
    static let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
}
