//
//  SQLite3.swift
//  SQLite
//
//  Created by Dima Bart on 2017-05-20.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

typealias _SQLite3       = OpaquePointer
typealias _StringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>
typealias _Int32Pointer  = UnsafeMutablePointer<Int32>

public class SQLite3 {
    
    public var isCacheEnabled = false
    
    private let sqlite: _SQLite3
    private var cachedStatements: [String: Statement] = [:]
    
    public var lastInsertID: Int {
        get {
            return Int(sqlite3_last_insert_rowid(self.sqlite))
        }
        set {
            sqlite3_set_last_insert_rowid(self.sqlite, sqlite3_int64(newValue))
        }
    }
    
    // ----------------------------------
    //  MARK: - Init -
    //
    public init(location: Location = .temporary, options: OpenOptions = [.readWrite, .create]) throws {
        let reference = UnsafeMutablePointer<_SQLite3?>.allocate(capacity: 1)
        defer {
            reference.deallocate(capacity: 1)
        }
        
        let status = sqlite3_open_v2(location.path, reference, options.rawValue, nil).status
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
    //  MARK: - Metadata -
    //
    public func columnMetadataFor(column: String, table: String, database: String? = nil) throws -> ColumnMetadata {
        
        let typePointer          = _StringPointer.allocate(capacity: 1)
        let collationPointer     = _StringPointer.allocate(capacity: 1)
        let notNullPointer       = _Int32Pointer.allocate(capacity: 1)
        let primaryKeyPointer    = _Int32Pointer.allocate(capacity: 1)
        let autoIncrementPointer = _Int32Pointer.allocate(capacity: 1)
        
        defer {
            typePointer.deallocate(capacity: 1)
            collationPointer.deallocate(capacity: 1)
            notNullPointer.deallocate(capacity: 1)
            primaryKeyPointer.deallocate(capacity: 1)
            autoIncrementPointer.deallocate(capacity: 1)
        }
        
        let status = sqlite3_table_column_metadata(
            self.sqlite,
            database,
            table,
            column,
            typePointer,
            collationPointer,
            notNullPointer,
            primaryKeyPointer,
            autoIncrementPointer
        ).status
        
        guard status == .ok else {
            throw status
        }
        
        return ColumnMetadata(
            type:            typePointer.pointee!.string,
            collation:       collationPointer.pointee!.string,
            isNotNull:       notNullPointer.pointee > 0,
            isPrimaryKey:    primaryKeyPointer.pointee > 0,
            isAutoIncrement: autoIncrementPointer.pointee > 0
        )
    }
    
    // ----------------------------------
    //  MARK: - Statement -
    //
    private func _prepare(query: String) throws -> _Statement {
        let reference = UnsafeMutablePointer<_Statement?>.allocate(capacity: 1)
        defer {
            reference.deallocate(capacity: 1)
        }
        
        let status = sqlite3_prepare_v2(self.sqlite, query, Int32(query.lengthOfBytes(using: .utf8)), reference, nil).status
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
