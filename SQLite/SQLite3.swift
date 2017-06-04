//
//  SQLite3.swift
//  SQLite
//
//  Created by Dima Bart on 2017-05-20.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

typealias _SQLite3 = OpaquePointer

public class SQLite3 {
    
    public var isCacheEnabled = false
    
    private let sqlite: _SQLite3
    private var cachedStatements: [String: Statement] = [:]
    
    // ----------------------------------
    //  MARK: - Init -
    //
    public init(at url: URL) throws {
        let reference = UnsafeMutablePointer<_SQLite3?>.allocate(capacity: 1)
        defer {
            reference.deallocate(capacity: 1)
        }
        
        let status = sqlite3_open(url.path, reference).status
        guard status == .ok else {
            throw status
        }
        
        self.sqlite = reference.pointee!
    }
    
    deinit {
        let status = sqlite3_close(self.sqlite).status
        if status != .ok {
            print("Failed to close database connection: \(status.description)")
        }
    }
    
    // ----------------------------------
    //  MARK: - Statement -
    //
    private func _prepare(query: String) throws -> _Statement {
        let reference = UnsafeMutablePointer<_Statement?>.allocate(capacity: 1)
        defer {
            reference.deallocate(capacity: 1)
        }
        
        let status = sqlite3_prepare_v2(self.sqlite, query, Int32(query.characters.count), reference, nil).status
        if status != .ok {
            throw status
        }
        
        return reference.pointee!
    }
    
    public func prepare(query: String) throws -> Statement {
        if let cachedStatement = try self.cachedStatementFor(query), self.isCacheEnabled {
            return cachedStatement
        }
        
        let statement = Statement(statement: try self._prepare(query: query))
        if self.isCacheEnabled {
            self.cacheStatement(statement, for: query)
        }
        
        return statement
    }
    
    // ----------------------------------
    //  MARK: - Statement Cache -
    //
    private func cachedStatementFor(_ key: String) throws -> Statement? {
        if let statement = self.cachedStatements[key] {
            try statement.reset()
            try statement.clearBindings()
            
            return statement
        }
        return nil
    }
    
    private func cacheStatement(_ statement: Statement, for key: String) {
        self.cachedStatements[key] = statement
    }
}
