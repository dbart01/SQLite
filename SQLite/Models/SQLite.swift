//
//  SQLite.swift
//  SQLite
//
//  Created by Dima Bart on 2017-05-20.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

typealias _SQLite        = OpaquePointer
typealias _StringPointer = UnsafeMutablePointer<UnsafePointer<Int8>?>
typealias _Int32Pointer  = UnsafeMutablePointer<Int32>

public class SQLite {
    
    public let hook: Hook
    
    public var isCacheEnabled = false
    
    public var lastInsertID: Int {
        get {
            return Int(sqlite3_last_insert_rowid(self.sqlite))
        }
        set {
            sqlite3_set_last_insert_rowid(self.sqlite, sqlite3_int64(newValue))
        }
    }
    
    private var cachedStatements: [String: Statement] = [:]
    
    internal let sqlite: _SQLite
    
    // ----------------------------------
    //  MARK: - Init -
    //
    public convenience init(location: Location = .temporary, options: OpenOptions = [.readWrite, .create]) throws {
        let reference = UnsafeMutablePointer<_SQLite?>.allocate(capacity: 1)
        defer {
            reference.deallocate()
        }
        
        let status = sqlite3_open_v2(location.path, reference, options.rawValue, nil).status
        guard status == .ok else {
            throw status
        }
        
        self.init(sqlite3: reference.pointee!)
    }
    
    internal init(sqlite3: _SQLite) {
        self.sqlite = sqlite3
        self.hook   = Hook(sqlite: sqlite3)
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
            typePointer.deallocate()
            collationPointer.deallocate()
            notNullPointer.deallocate()
            primaryKeyPointer.deallocate()
            autoIncrementPointer.deallocate()
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
    public func prepare(query: String) throws -> Statement {
        if let cachedStatement = try self.cachedStatementFor(query), self.isCacheEnabled {
            return cachedStatement
        }
        
        let statement = try Statement(sqlite: self, query: query)
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
    
    // ----------------------------------
    //  MARK: - Pragma -
    //
    public func get<T>(pragma: PragmaDescription<T>) throws -> T? {
        var value: T?
        try self.execute(query: "PRAGMA \(pragma.key);", rowHandler: { result, statement in
            if let rawValue: T.RawValue = try statement.value(at: 0) {
                value = T(rawValue: rawValue)
            }
        })
        return value
    }
    
    public func set<T>(pragma: PragmaDescription<T>, value: T) throws -> Bool {
        let result = try self.execute(query: "PRAGMA \(pragma.key) = \(value.sqlValue);")
        return result == .done || result == .row
    }
    
    // ----------------------------------
    //  MARK: - Execute -
    //
    @discardableResult
    public func execute(query: String, arguments: Any...) throws -> Statement.Result {
        let statement = try self.statement(for: query, bindingTo: arguments)
        return try statement.step()
    }
    
    public func execute(query: String, arguments: Any..., rowHandler: Statement.StepRowHandler) throws {
        let statement = try self.statement(for: query, bindingTo: arguments)
        
        return try statement.stepRows { result, statement in
            try rowHandler(result, statement)
        }
    }
    
    public func execute(query: String, arguments: Any..., dictionaryHandler: Statement.StepDictionaryHandler) throws {
        let statement = try self.statement(for: query, bindingTo: arguments)
        
        return try statement.stepDictionaries { result, statement in
            dictionaryHandler(result, statement)
        }
    }
    
    private func statement(for query: String, bindingTo arguments: [Any]) throws -> Statement {
        let statement = try self.prepare(query: query)
        
        for (index, argument) in arguments.enumerated() {
            try statement.bind(argument, to: index)
        }
        
        return statement
    }
    
    // ----------------------------------
    //  MARK: - Checkpoint -
    //
    @discardableResult
    public func checkpoint(_ type: Checkpoint = .passive) -> Status {
        return sqlite3_wal_checkpoint_v2(self.sqlite, nil, type.rawValue, nil, nil).status
    }
    
    // ----------------------------------
    //  MARK: - Transactions -
    //
    @discardableResult
    public func performTransaction(_ type: Transaction = .deferred, transaction: TransactionOperation) throws -> Transaction.Result {
        try self.execute(query: "BEGIN \(type.sqlRepresentation) TRANSACTION;")
        do {
            
            let result = try transaction()
            switch result {
            case .commit:   try self.execute(query: "COMMIT TRANSACTION;")
            case .rollback: try self.execute(query: "ROLLBACK TRANSACTION;")
            }
            return result
            
        } catch {
            try self.execute(query: "ROLLBACK TRANSACTION;")
            throw error
        }
    }
}
