//
//  SQLite.Blob.swift
//  SQLite
//
//  Created by Dima Bart on 2018-04-02.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

typealias _Blob = OpaquePointer

extension SQLite {
    public class Blob {

        internal let sqlite: _SQLite
        internal let blob:   _Blob
        
        public var count: Int {
            return Int(sqlite3_blob_bytes(self.blob))
        }
        
        // ----------------------------------
        //  MARK: - Init -
        //
        internal convenience init(sqlite: _SQLite, database: String, table: String, column: String, rowID: Int, mode: Mode) throws {
            let reference = UnsafeMutablePointer<_Blob?>.allocate(capacity: 1)
            defer {
                reference.deallocate()
            }
            
            let status = sqlite3_blob_open(sqlite, database, table, column, sqlite3_int64(rowID), mode.rawValue, reference).status
            guard status == .ok else {
                throw status
            }
            
            self.init(sqlite: sqlite, blob: reference.pointee!)
        }
        
        internal init(sqlite: _SQLite, blob: _Blob) {
            self.sqlite = sqlite
            self.blob   = blob
        }
        
        deinit {
            let status = sqlite3_blob_close(self.blob).status
            if status != .ok {
                print("Failed to close blob: \(status.description)")
            }
        }
        
        // ----------------------------------
        //  MARK: - I/O -
        //
        public func read(count: Int, at offset: Int = 0) throws -> Data {
            var buffer = Data(count: count)
            try buffer.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<UInt8>) in
                let status = sqlite3_blob_read(self.blob, bytes, Int32(count), Int32(offset)).status
                if status != .ok {
                    throw status
                }
            }
            
            return buffer
        }
        
        public func write(_ data: Data, at offset: Int = 0) throws {
            try data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
                let status = sqlite3_blob_write(self.blob, bytes, Int32(data.count), Int32(offset)).status
                if status != .ok {
                    throw status
                }
            }
        }
        
        public func reopen(rowID: Int) throws {
            let status = sqlite3_blob_reopen(self.blob, sqlite3_int64(rowID)).status
            if status != .ok {
                throw status
            }
        }
    }
}

// ----------------------------------
//  MARK: - Mode -
//
extension SQLite.Blob {
    public enum Mode: RawRepresentable {
        
        case readOnly
        case readWrite
        
        public typealias RawValue = Int32
        
        public var rawValue: RawValue {
            switch self {
            case .readOnly:  return 0
            case .readWrite: return 1
            }
        }
        
        public init?(rawValue: RawValue) {
            switch rawValue {
            case type(of: self).readOnly.rawValue:  self = .readOnly
            default:                                self = .readWrite
            }
        }
    }
}
