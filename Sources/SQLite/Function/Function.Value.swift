//
//  Function.Value.swift
//  SQLite
//
//  Created by Dima Bart on 2018-04-05.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation
import sqlite3

typealias _Value = OpaquePointer

extension Function {
    public struct Value {
        
        private let value: _Value
        
        // ----------------------------------
        //  MARK: - Init -
        //
        internal static func collection(argc: Int, argv: UnsafeMutablePointer<_Value?>) -> [Value] {
            var container: [Value] = []
            for i in 0..<argc {
                let value = Value(value: argv.advanced(by: i).pointee!)
                container.append(value)
            }
            return container
        }
        
        internal init(value: _Value) {
            self.value = value
        }
        
        // ----------------------------------
        //  MARK: - Values -
        //
        public func typed<T>() throws -> T? {
            
            if T.self == Bool.self   { return (self.integer.boolValue as! T) }
            
            if T.self == Int.self   { return (Int(self.integer)   as! T) }
            if T.self == Int8.self  { return (Int8(self.integer)  as! T) }
            if T.self == Int16.self { return (Int16(self.integer) as! T) }
            if T.self == Int32.self { return (Int32(self.integer) as! T) }
            if T.self == Int64.self { return (Int64(self.integer) as! T) }
            
            if T.self == UInt.self   { return (UInt(self.integer)   as! T) }
            if T.self == UInt8.self  { return (UInt8(self.integer)  as! T) }
            if T.self == UInt16.self { return (UInt16(self.integer) as! T) }
            if T.self == UInt32.self { return (UInt32(self.integer) as! T) }
            if T.self == UInt64.self { return (UInt64(self.integer) as! T) }
            
            if T.self == String.self {
                if let string = self.string {
                    return (string as! T)
                }
                return nil
            }
            
            if T.self == URL.self {
                if let string = self.string,
                    let url = URL(string: string) {
                    
                    return (url as! T)
                }
                return nil
            }
            
            if T.self == Decimal.self { return (Decimal(self.string) as! T) }
            if T.self == Float.self   { return (Float(self.double)   as! T) }
            if T.self == Double.self  { return (Double(self.double)  as! T) }
            
            if T.self == Data.self {
                if let data = self.blob {
                    return (data as! T)
                }
                return nil
            }
            
            throw Error.invalidType
        }
        
        public var integer: Int {
            return Int(sqlite3_value_int64(self.value))
        }
        
        public var double: Double {
            return sqlite3_value_double(self.value)
        }
        
        public var string: String? {
            if let text = sqlite3_value_text(self.value) {
                return text.string
            }
            return nil
        }
        
        public var blob: Data? {
            let byteCount = sqlite3_value_bytes(self.value)
            if let pointer = sqlite3_value_blob(self.value) {
                return Data(bytes: pointer, count: Int(byteCount))
            }
            return nil
        }
    }
}

// ----------------------------------
//  MARK: - Error -
//
extension Function.Value {
    public enum Error: Swift.Error {
        case invalidType
    }
}
