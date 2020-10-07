//
//  SQLite+Database.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-20.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
import sqlite3
@testable import SQLite

extension SQLite {
    
    static func `default`() -> SQLite {
        let sqlite = try! SQLite(location: .memory)
        sqlite.populate()
        return sqlite
    }
    
    static func local() -> SQLite {
        let name   = UUID().uuidString
        let url    = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(name).sqlite")
        let sqlite = try! SQLite(location: .disk(url))
        sqlite.populate()
        return sqlite
    }
    
    static func emptyInMemory(options: OpenOptions = [.readWrite, .create]) -> SQLite {
        return try! SQLite(location: .memory, options: options)
    }
    
    static func prepared(query: String, configuration: ((SQLite) -> Void)? = nil) -> Statement {
        let sqlite = self.default()
        configuration?(sqlite)
        
        return try! sqlite.prepare(query: query)
    }
}

// MARK: - Test Schema -

private extension SQLite {
    
    func populate() {
        let query = """
        CREATE TABLE "animal" (
            "id" INTEGER PRIMARY KEY ON CONFLICT FAIL AUTOINCREMENT,
            "name" TEXT,
            "type" TEXT,
            "length" REAL,
            "image" BLOB,
            "thumb" BLOB
        );
        """
        
        let result = try! self.execute(query: query)
        XCTAssertEqual(result, .done)
        
        try! self.performTransaction(.deferred) {
            try self.execute(query: "INSERT INTO animal VALUES (1, 'bulldog', 'dog', 44.76, NULL, NULL);")
            try self.execute(query: "INSERT INTO animal VALUES (2, 'red squirrel', 'rodent', 23.34, NULL, NULL);")
            try self.execute(query: "INSERT INTO animal VALUES (3, NULL, 'mammal', 4279.281, X'FEEDBEEF', NULL);")
            try self.execute(query: "INSERT INTO animal VALUES (4, 'tiger', 'feline', 1321.84, NULL, NULL);")
            try self.execute(query: "INSERT INTO animal VALUES (5, 'lion', 'feline', 1185.48, NULL, NULL);")
            try self.execute(query: "INSERT INTO animal VALUES (6, 'puma', 'feline', 978.52, NULL, NULL);")
            try self.execute(query: "INSERT INTO animal VALUES (7, 'black squirrel', 'rodent', 37.82, NULL, NULL);")
            try self.execute(query: "INSERT INTO animal VALUES (8, 'greyhound', 'dog', 63.578, NULL, NULL);")
            try self.execute(query: "INSERT INTO animal VALUES (9, 'aligator', 'reptile', 3892.75, NULL, NULL);")
            try self.execute(query: "INSERT INTO animal VALUES (10, 'crocodile', 'reptile', 2987.83, NULL, NULL);")
            try self.execute(query: "INSERT INTO animal VALUES (11, 'iguana', 'reptile', 39.92, NULL, NULL);")
            try self.execute(query: "INSERT INTO animal VALUES (999, 'dragon', 'mythical', NULL, NULL, NULL);")
            
            return .commit
        }
        
        self.lastInsertID = 0
    }
}
