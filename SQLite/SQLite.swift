//
//  Database.swift
//  SQLite
//
//  Created by Dima Bart on 2017-05-20.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

typealias _SQLite3 = OpaquePointer

public class SQLite3 {
    
    private let sqlite: _SQLite3
    
    // ----------------------------------
    //  MARK: - Init -
    //
    public init(at url: URL) throws {
        let reference = UnsafeMutablePointer<_SQLite3?>.allocate(capacity: 1)
        
        let status = sqlite3_open(url.path, reference).status
        guard status == .ok else {
            throw status
        }
        
        self.sqlite = reference.pointee!
        reference.deallocate(capacity: 1)
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
    private func prepare(query: String) throws -> _Statement {
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
        let statement: _Statement = try self.prepare(query: query)
        
        return Statement(query: query, statement: statement)
    }
}
