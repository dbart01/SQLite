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
    
    public enum Result {
        case done
        case row
    }
    
    let statement: _Statement
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(statement: _Statement) {
        self.statement = statement
    }
    
    // ----------------------------------
    //  MARK: - Query -
    //
    public var query: String {
        return String(cString: sqlite3_sql(self.statement))
    }
    
    public var expandedQuery: String {
        return String(cString: sqlite3_expanded_sql(self.statement))
    }
    
    // ----------------------------------
    //  MARK: - Parameters -
    //
    public var parameterCount: Int {
        return Int(sqlite3_bind_parameter_count(self.statement))
    }
    
    public func parameterIndex(for parameter: String) -> Int? {
        let index = sqlite3_bind_parameter_index(self.statement, parameter)
        if index > 0 {
            return Int(index) - 1
        }
        return nil
    }
    
    public func parameterName(for index: Int) -> String? {
        if let name = sqlite3_bind_parameter_name(self.statement, Int32(index) + 1) {
            return String(cString: name)
        }
        return nil
    }
    
    // ----------------------------------
    //  MARK: - Bind -
    //
    public func bind<T: Serializable>(_ value: T?, column: Int) throws {
        
        let columnIndex = Int32(column) + 1
        
        let status: Status
        
        if let value = value {
            switch value.value {
            case .integer(let int):
                status = sqlite3_bind_int(self.statement, columnIndex, Int32(int)).status
            case .double(let double):
                status = sqlite3_bind_double(self.statement, columnIndex, double).status
            case .string(let string):
                status = sqlite3_bind_text(self.statement, columnIndex, string.cString(using: .utf8), -1, Destructor.transient).status
            case .blob(let data):
                status = data.withUnsafeBytes {
                    return sqlite3_bind_blob(self.statement, columnIndex, $0, Int32(data.count), Destructor.transient).status
                }
            }
            
        } else {
            status = sqlite3_bind_null(self.statement, columnIndex).status
        }
        
        guard status == .ok else {
            throw status
        }
    }
    
    // ----------------------------------
    //  MARK: - Step -
    //
    public func step() throws -> Result {
        let status = sqlite3_step(self.statement).status
        switch status {
        case .done: fallthrough
        case .ok:   return .done
        case .row:  return .row
        default:
            throw status
        }
    }
}
