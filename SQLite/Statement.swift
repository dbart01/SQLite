//
//  Statement.swift
//  SQLite
//
//  Created by Dima Bart on 2017-05-28.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

typealias _Statement = OpaquePointer

public class Statement {
    
    public let query: String
    
    let statement: _Statement
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(query: String, statement: _Statement) {
        self.query     = query
        self.statement = statement
    }
}
