//
//  Statement+Serializable.swift
//  SQLite
//
//  Created by Dima Bart on 2017-06-05.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

extension Statement {
    
    public typealias RowHandler = (Statement) -> Void
    public typealias DictionaryHandler = ([String: Any]) -> Void
    
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
    
    @discardableResult
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
    
    @discardableResult
    public func stepDictionary(handler: DictionaryHandler? = nil) throws -> Result {
        
        return try self.stepRows { statement in
            
            var dictionary = [String: Any]()
            for index in 0..<statement.columnCount {
                
                let type = statement.columnType(at: index)!
                let name = statement.columnName(at: index)
                
                switch type {
                case .integer:
                    dictionary[name] = statement.integer(at: index)
                case .float:
                    dictionary[name] = statement.double(at: index)
                case .text:
                    dictionary[name] = statement.string(at: index)
                case .blob:
                    dictionary[name] = statement.blob(at: index)
                case .null:
                    break
                }
            }
            
            handler?(dictionary)
        }
    }
}
