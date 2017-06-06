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
    
    public var isBusy: Bool {
        return sqlite3_stmt_busy(self.statement) != 0
    }
    
    public var isReadOnly: Bool {
        return sqlite3_stmt_readonly(self.statement) != 0
    }
    
    let statement: _Statement
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(statement: _Statement) {
        self.statement = statement
    }
    
    deinit {
        try? reset()
        try? finalize()
    }
    
    // ----------------------------------
    //  MARK: - Query -
    //
    public var query: String {
        return sqlite3_sql(self.statement).string
    }
    
    public var expandedQuery: String {
        return sqlite3_expanded_sql(self.statement).string
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
            return self.convert(toZeroBased: index)
        }
        return nil
    }
    
    public func parameterName(for index: Int) -> String? {
        if let name = sqlite3_bind_parameter_name(self.statement, self.convert(toOneBased: index)) {
            return name.string
        }
        return nil
    }
    
    // ----------------------------------
    //  MARK: - Index Conversion -
    //
    private func convert(toZeroBased index: Int32) -> Int {
        return Int(index - 1)
    }
    
    private func convert(toOneBased index: Int) -> Int32 {
        return Int32(index + 1)
    }
    
    // ----------------------------------
    //  MARK: - Bind -
    //    
    public func bind(integer: Int?, to column: Int) throws {
        guard let integer = integer else {
            try self.bindNull(to: column)
            return
        }
        
        let status = sqlite3_bind_int64(self.statement, self.convert(toOneBased: column), sqlite3_int64(integer)).status
        guard status == .ok else {
            throw status
        }
    }
    
    public func bind(double: Double?, to column: Int) throws {
        guard let double = double else {
            try self.bindNull(to: column)
            return
        }
        
        let status = sqlite3_bind_double(self.statement, self.convert(toOneBased: column), double).status
        guard status == .ok else {
            throw status
        }
    }
    
    public func bind(string: String?, to column: Int) throws {
        guard let string = string else {
            try self.bindNull(to: column)
            return
        }
        
        let status = sqlite3_bind_text(self.statement, self.convert(toOneBased: column), string.cString(using: .utf8), -1, Destructor.transient).status
        guard status == .ok else {
            throw status
        }
    }
    
    public func bind(blob: Data?, to column: Int) throws {
        guard let blob = blob else {
            try self.bindNull(to: column)
            return
        }
        
        let status = blob.withUnsafeBytes { bytes in
            return sqlite3_bind_blob(self.statement, self.convert(toOneBased: column), bytes, Int32(blob.count), Destructor.transient).status
        }
        guard status == .ok else {
            throw status
        }
    }
    
    public func bindNull(to column: Int) throws {
        let status = sqlite3_bind_null(self.statement, self.convert(toOneBased: column)).status
        guard status == .ok else {
            throw status
        }
    }
    
    // ----------------------------------
    //  MARK: - Columns -
    //
    public var columnCount: Int {
        return Int(sqlite3_column_count(self.statement))
    }
    
    public func columnName(at column: Int) -> String {
        return sqlite3_column_name(self.statement, Int32(column)).string
    }
    
    public func columnType(at column: Int) -> ColumnType? {
        return sqlite3_column_type(self.statement, Int32(column)).columnType
    }
    
    public func columnByteCount(at column: Int) -> Int {
        return Int(sqlite3_column_bytes(self.statement, Int32(column)))
    }
    
//    public func value<T: Deserializable>(at column: Int) throws -> T? {
//        assert(column < self.columnCount)
//        
//        let columnIndex = column + 1
//        
//        let value: Value
//        
//        switch T.type {
//        case .integer: value = .integer( self.integer(at: columnIndex) )
//        case .double:  value = .double(  self.double(at: columnIndex)  )
//        case .string:  value = .string(  self.string(at: columnIndex)  )
//        case .blob:    value = .blob(    self.blob(at: columnIndex)    )
//        }
//        
//        return try T.from(value: value)
//    }
    
    public func integer(at column: Int) -> Int {
        return Int(sqlite3_column_int64(self.statement, Int32(column)))
    }
    
    public func double(at column: Int) -> Double {
        return sqlite3_column_double(self.statement, Int32(column))
    }
    
    public func string(at column: Int) -> String? {
        if let text = sqlite3_column_text(self.statement, Int32(column)) {
            return text.string
        }
        return nil
    }
    
    public func blob(at column: Int) -> Data? {
        if let pointer = sqlite3_column_blob(self.statement, Int32(column)) {
            let bytes  = sqlite3_column_bytes(self.statement, Int32(column))
            return Data(bytes: pointer, count: Int(bytes))
        }
        return nil
    }
    
    // ----------------------------------
    //  MARK: - Step -
    //
    @discardableResult
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
    
    // ----------------------------------
    //  MARK: - Reset -
    //
    private func finalize() throws {
        let status = sqlite3_finalize(self.statement).status
        if status != .ok {
            throw status
        }
    }
    
    public func clearBindings() throws {
        let status = sqlite3_clear_bindings(self.statement).status
        if status != .ok {
            throw status
        }
    }
    
    public func reset() throws {
        let status = sqlite3_reset(self.statement).status
        if status != .ok {
            throw status
        }
    }
}

// ----------------------------------
//  MARK: - Result -
//
extension Statement {
    public enum Result {
        case done
        case row
    }
}

// ----------------------------------
//  MARK: - Column Type -
//
extension Statement {
    public enum ColumnType {
        case integer
        case float
        case text
        case blob
        case null
        
        public init?(type: Int32) {
            switch type {
            case SQLITE_INTEGER: self = .integer
            case SQLITE_FLOAT:   self = .float
            case SQLITE_TEXT:    self = .text
            case SQLITE_BLOB:    self = .blob
            case SQLITE_NULL:    self = .null
            default:
                return nil
            }
        }
    }
}

extension Int32 {
    var columnType: Statement.ColumnType? {
        return Statement.ColumnType(type: self)
    }
}
