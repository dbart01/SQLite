//
//  SQLite+Execute.swift
//  SQLite
//
//  Created by Dima Bart on 2017-06-04.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

extension SQLite3 {
    
    public func execute(query: String, arguments: Serializable..., rowHandler: Statement.RowHandler? = nil) throws -> Statement.Result {
        let statement = try self.prepare(query: query)
        
        for (index, argument) in arguments.enumerated() {
            try statement.bind(serializable: argument, to: index)
        }
        
        return try statement.stepRows(handler: rowHandler)
    }
}
