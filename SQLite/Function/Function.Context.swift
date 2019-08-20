//
//  Function.Context.swift
//  SQLite
//
//  Created by Dima Bart on 2018-04-05.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

typealias _Context = OpaquePointer

extension Function {
    public struct Context {
        
        internal let context: _Context
        
        // ----------------------------------
        //  MARK: - Init -
        //
        internal init(context: _Context) {
            self.context = context
        }
        
        // ----------------------------------
        //  MARK: - Bind -
        //
        public func bind<T>(_ value: T?) {
            guard let value = value else {
                return self.bindNull()
            }
            
            /* -------------------------------------
             ** We're dealing with `Any` types here.
             ** In order to extract boxed optionals
             ** that we're cast as `Any`, we have to
             ** do some protocol trickery here.
             */
            if let optional = value as? OptionalProtocol {
                if optional.hasSome {
                    self.bind(optional.some)
                } else {
                    self.bind(nil as Optional<String>) // String could be any type
                }
                return
            }
            
            switch value {
                
            case let bool as Bool:
                self.bind(integer: bool ? 1 : 0)
                
            case let integer as Int:
                self.bind(integer: integer)
            case let integer as Int8:
                self.bind(integer: Int(integer))
            case let integer as Int16:
                self.bind(integer: Int(integer))
            case let integer as Int32:
                self.bind(integer: Int(integer))
            case let integer as Int64:
                self.bind(integer: Int(integer))
                
            // TODO: UInt64 won't fit into Int
            case let integer as UInt:
                self.bind(integer: Int(integer))
            case let integer as UInt8:
                self.bind(integer: Int(integer))
            case let integer as UInt16:
                self.bind(integer: Int(integer))
            case let integer as UInt32:
                self.bind(integer: Int(integer))
            case let integer as UInt64:
                self.bind(integer: Int(integer))
                
            case let string as String:
                self.bind(string: string)
            case let url as URL:
                self.bind(string: url.absoluteString)
                
            case let decimal as Decimal:
                self.bind(string: decimal.description)
                
            case let float as Float:
                self.bind(double: Double(float))
            case let float as Double:
                self.bind(double: float)
                
            case let data as Data:
                self.bind(blob: data)
                
            default:
                fatalError("Attempt to bind unsupported data type: \(String(describing: T.self))")
            }
        }
        
        public func bind(integer: Int?) {
            guard let integer = integer else {
                self.bindNull()
                return
            }
            
            sqlite3_result_int64(self.context, sqlite3_int64(integer))
        }
        
        public func bind(double: Double?) {
            guard let double = double else {
                self.bindNull()
                return
            }
            
            sqlite3_result_double(self.context, double)
        }
        
        public func bind(string: String?) {
            guard let string = string else {
                self.bindNull()
                return
            }
            
            sqlite3_result_text(self.context, string.cString(using: .utf8), -1, Destructor.transient)
        }
        
        public func bind(blob: Data?) {
            guard let blob = blob else {
                self.bindNull()
                return
            }
            
            blob.withUnsafeBytes { bytes in
                sqlite3_result_blob(self.context, bytes.baseAddress, Int32(blob.count), Destructor.transient)
            }
        }
        
        public func bindNull() {
            sqlite3_result_null(self.context)
        }
        
        public func bind(error: Error, status: Status? = nil) {
            switch error {
            case .message(let message):
                sqlite3_result_error(self.context, message, -1)
            case .tooBig:
                sqlite3_result_error_toobig(self.context)
            case .noMemory:
                sqlite3_result_error_nomem(self.context)
            }
            
            if let status = status {
                sqlite3_result_error_code(self.context, status.rawValue)
            }
        }
    }
}

// ----------------------------------
//  MARK: - Error -
//
extension Function.Context {
    public enum Error: Equatable {
        case message(String)
        case tooBig
        case noMemory
    }
}
