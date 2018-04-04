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
    
    public var isCacheEnabled = false {
        willSet(enabled) {
            if !enabled && self.isCacheEnabled {
                self.cachedStatements.removeAll()
            }
        }
    }
    
    public var lastInsertID: Int {
        get {
            return Int(sqlite3_last_insert_rowid(self.sqlite))
        }
        set {
            sqlite3_set_last_insert_rowid(self.sqlite, sqlite3_int64(newValue))
        }
    }
    
    public var changeCount: Int {
        return Int(sqlite3_changes(self.sqlite))
    }
    
    public var totalChangeCount: Int {
        return Int(sqlite3_total_changes(self.sqlite))
    }
    
    private var cachedStatements: [String: Statement] = [:]
    
    internal var errorMessage: String {
        return sqlite3_errmsg(self.sqlite).string
    }
    
    internal var errorStatus: Status {
        return sqlite3_errcode(self.sqlite).status
    }
    
    internal let sqlite: _SQLite
    
    // ----------------------------------
    //  MARK: - Init -
    //
    public convenience init(location: Location = .temporary, options: OpenOptions = [.readWrite, .create]) throws {
        let sqlite = try initialize(_SQLite.self) {
            sqlite3_open_v2(location.path, $0, options.rawValue, nil).status
        }
        
        self.init(sqlite: sqlite)
    }
    
    internal init(sqlite: _SQLite) {
        self.sqlite = sqlite
        self.hook   = Hook(sqlite: sqlite)
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
        
        var type:          UnsafePointer<Int8>?
        var collation:     UnsafePointer<Int8>?
        var notNull:       Int32 = -1
        var primaryKey:    Int32 = -1
        var autoIncrement: Int32 = -1
        
        var status = Status.abort
        
        withUnsafeMutablePointer(to: &type) { type in
            withUnsafeMutablePointer(to: &collation) { collation in
                withUnsafeMutablePointer(to: &notNull) { notNull in
                    withUnsafeMutablePointer(to: &primaryKey) { primaryKey in
                        withUnsafeMutablePointer(to: &autoIncrement) { autoIncrement in
                            status = sqlite3_table_column_metadata(
                                self.sqlite,
                                database,
                                table,
                                column,
                                type,
                                collation,
                                notNull,
                                primaryKey,
                                autoIncrement
                            ).status
                        }
                    }
                }
            }
        }
        
        guard status == .ok else {
            throw status
        }
        
        return ColumnMetadata(
            type:            type!.string,
            collation:       collation!.string,
            isNotNull:       notNull > 0,
            isPrimaryKey:    primaryKey > 0,
            isAutoIncrement: autoIncrement > 0
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
    //  MARK: - Blob -
    //
    public func open(table: String, column: String, rowID: Int, mode: Blob.Mode) throws -> Blob {
        return try Blob(
            sqlite:   self.sqlite,
            database: "main",
            table:    table,
            column:   column,
            rowID:    rowID,
            mode:     mode
        )
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
    
    // ----------------------------------
    //  MARK: - Backup -
    //
    public func backup(from sourceName: String = "main", to destination: SQLite, database destinationName: String = "main") throws -> Backup {
        return try Backup(
            from:            self,
            sourceName:      sourceName,
            to:              destination,
            destinationName: destinationName
        )
    }
}
