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

    public typealias StepRowHandler        = (Result, Statement) throws -> Void
    public typealias StepDictionaryHandler = (Result, [String: Any]) -> Void
    
    public private(set) weak var sqlite: SQLite?
    
    public var isBusy: Bool {
        return sqlite3_stmt_busy(self.statement) != 0
    }
    
    public var isReadOnly: Bool {
        return sqlite3_stmt_readonly(self.statement) != 0
    }
        
    private var isFinalized = false
    
    internal let statement: _Statement
    
    // ----------------------------------
    //  MARK: - Init -
    //
    convenience init(sqlite: SQLite, query: String) throws {
        guard query.count > 0 else {
            throw Status.error
        }
        
        let statement = try initialize(_Statement.self) {
            sqlite3_prepare_v2(sqlite.sqlite, query, Int32(query.lengthOfBytes(using: .utf8)), $0, nil).status
        }
        
        self.init(sqlite: sqlite, statement: statement)
    }
    
    internal init(sqlite: SQLite, statement: _Statement) {
        self.sqlite    = sqlite
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
    public func bind<T>(_ value: T?, to column: Int) throws {
        guard let value = value else {
            return try self.bindNull(to: column)
        }
        
        /* -------------------------------------
         ** We're dealing with `Any` types here.
         ** In order to extract boxed optionals
         ** that we're cast as `Any`, we have to
         ** do some protocol trickery here.
         */
        if let optional = value as? OptionalProtocol {
            if optional.hasSome {
                try self.bind(optional.some, to: column)
            } else {
                try self.bind(nil as Optional<String>, to: column) // String could be any type
            }
            return
        }
        
        switch value {
            
        case let bool as Bool:
            try self.bind(integer: bool ? 1 : 0, to: column)
            
        case let integer as Int:
            try self.bind(integer: integer, to: column)
        case let integer as Int8:
            try self.bind(integer: Int(integer), to: column)
        case let integer as Int16:
            try self.bind(integer: Int(integer), to: column)
        case let integer as Int32:
            try self.bind(integer: Int(integer), to: column)
        case let integer as Int64:
            try self.bind(integer: Int(integer), to: column)
            
        // TODO: UInt64 won't fit into Int
        case let integer as UInt:
            try self.bind(integer: Int(integer), to: column)
        case let integer as UInt8:
            try self.bind(integer: Int(integer), to: column)
        case let integer as UInt16:
            try self.bind(integer: Int(integer), to: column)
        case let integer as UInt32:
            try self.bind(integer: Int(integer), to: column)
        case let integer as UInt64:
            try self.bind(integer: Int(integer), to: column)
            
        case let string as String:
            try self.bind(string: string, to: column)
        case let url as URL:
            try self.bind(string: url.absoluteString, to: column)
            
        case let decimal as Decimal:
            try self.bind(string: decimal.description, to: column)
            
        case let float as Float:
            try self.bind(double: Double(float), to: column)
        case let float as Double:
            try self.bind(double: float, to: column)
            
        case let data as Data:
            try self.bind(blob: data, to: column)
            
        default:
            throw Error.invalidType
        }
    }
    
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
    public var dataCount: Int {
        return Int(sqlite3_data_count(self.statement))
    }
    
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
    
    // ----------------------------------
    //  MARK: - Values -
    //
    public func value<T>(at column: Int) throws -> T? {
        
        if T.self == Bool.self   { return (self.integer(at: column).boolValue as! T) }
        
        if T.self == Int.self   { return (Int(self.integer(at: column))   as! T) }
        if T.self == Int8.self  { return (Int8(self.integer(at: column))  as! T) }
        if T.self == Int16.self { return (Int16(self.integer(at: column)) as! T) }
        if T.self == Int32.self { return (Int32(self.integer(at: column)) as! T) }
        if T.self == Int64.self { return (Int64(self.integer(at: column)) as! T) }
        
        if T.self == UInt.self   { return (UInt(self.integer(at: column))   as! T) }
        if T.self == UInt8.self  { return (UInt8(self.integer(at: column))  as! T) }
        if T.self == UInt16.self { return (UInt16(self.integer(at: column)) as! T) }
        if T.self == UInt32.self { return (UInt32(self.integer(at: column)) as! T) }
        if T.self == UInt64.self { return (UInt64(self.integer(at: column)) as! T) }
        
        if T.self == String.self {
            if let string = self.string(at: column) {
                return (string as! T)
            }
            return nil
        }
        
        if T.self == URL.self {
            if let string = self.string(at: column),
                let url = URL(string: string) {
                
                return (url as! T)
            }
            return nil
        }
        
        if T.self == Decimal.self { return (Decimal(self.string(at: column)) as! T) }
        if T.self == Float.self   { return (Float(self.double(at: column))   as! T) }
        if T.self == Double.self  { return (Double(self.double(at: column))  as! T) }
        
        if T.self == Data.self {
            if let data = self.blob(at: column) {
                return (data as! T)
            }
            return nil
        }
        
        throw Error.invalidType
    }
    
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
            return Data(bytes: pointer, count: self.columnByteCount(at: column))
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
    
    public func stepRows(using rowHandler: StepRowHandler) throws {
        var result = Result.done
        
        repeat {
            result = try self.step()
            if result == .row {
                try rowHandler(result, self)
            }
        } while result == .row
    }
    
    public func stepDictionaries(using dictionaryHandler: StepDictionaryHandler) throws {
        try self.stepRows { result, statement in
            
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
            
            dictionaryHandler(result, dictionary)
        }
    }
    
    // ----------------------------------
    //  MARK: - Reset -
    //
    internal func finalize() throws {
        guard !self.isFinalized else {
            return
        }
        self.isFinalized = true
        
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

#if SQLITE_ENABLE_COLUMN_METADATA

// --------------------------------------
//  MARK: - Column Metadata Extension -
//
extension Statement {
    public func columnTableName(at column: Int) -> String? {
        if let name = sqlite3_column_table_name(self.statement, Int32(column)) {
            return name.string
        }
        return nil
    }
    
    public func columnDatabaseName(at column: Int) -> String? {
        if let name = sqlite3_column_database_name(self.statement, Int32(column)) {
            return name.string
        }
        return nil
    }
    
    public func columnOriginName(at column: Int) -> String? {
        if let name = sqlite3_column_origin_name(self.statement, Int32(column)) {
            return name.string
        }
        return nil
    }
}
    
#endif

// ----------------------------------
//  MARK: - Error -
//
extension Statement {
    public enum Error: Swift.Error {
        case invalidType
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
//  MARK: - Private -
//
extension Int {
    var boolValue: Bool {
        return self > 0
    }
}

extension Decimal {
    init?(_ string: String?) {
        guard let string = string else {
            return nil
        }
        self.init(string: string)
    }
}

// ----------------------------------
//  MARK: - OptionalProtocol -
//
private protocol OptionalProtocol {
    var hasSome: Bool { get }
    var some:    Any  { get }
}

// TODO: Extract and write tests
extension Optional: OptionalProtocol {
    
    var hasSome: Bool {
        switch self {
        case .some: return true
        case .none: return false
        }
    }
    
    var some: Any {
        switch self {
        case .some(let value):
            return value
        case .none:
            return self!
        }
    }
}
