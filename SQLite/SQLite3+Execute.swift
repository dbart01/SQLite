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

extension Statement {
    
    public typealias RowHandler = (Statement) -> Void
    
    public func bind(serializable: Serializable?, to column: Int) throws {
        guard let serializable = serializable else {
            try self.bindNull(to: column)
            return
        }
        
        switch serializable.value {
        case .integer(let int):   try self.bind(integer: int,    to: column)
        case .double(let double): try self.bind(double:  double, to: column)
        case .string(let string): try self.bind(string:  string, to: column)
        case .blob(let data):     try self.bind(blob:    data,   to: column)
        }
    }
    
    public func stepRows(handler: RowHandler? = nil) throws -> Result {
        var result = Result.done
        
        repeat {
            result = try self.step()
            if result == .row {
                handler?(self)
            }
        } while result == .row
        
        return result
    }
}
