//
//  SQLite+Database.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-20.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
import SQLite

extension SQLite {
    
    static func local() -> SQLite {
        let sqlite = try! SQLite(location: .memory)
        
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
        
        let result = try! sqlite.execute(query: query)
        XCTAssertEqual(result, .done)
        
        try! sqlite.performTransaction(.deferred) {
            try sqlite.execute(query: "INSERT INTO animal VALUES (1, 'bulldog', 'dog', 44.76, NULL, NULL);")
            try sqlite.execute(query: "INSERT INTO animal VALUES (2, 'red squirrel', 'rodent', 23.34, NULL, NULL);")
            try sqlite.execute(query: "INSERT INTO animal VALUES (3, NULL, 'mammal', 4279.281, X'FEEDBEEF', NULL);")
            try sqlite.execute(query: "INSERT INTO animal VALUES (4, 'tiger', 'feline', 1321.84, NULL, NULL);")
            try sqlite.execute(query: "INSERT INTO animal VALUES (5, 'lion', 'feline', 1185.48, NULL, NULL);")
            try sqlite.execute(query: "INSERT INTO animal VALUES (6, 'puma', 'feline', 978.52, NULL, NULL);")
            try sqlite.execute(query: "INSERT INTO animal VALUES (7, 'black squirrel', 'rodent', 37.82, NULL, NULL);")
            try sqlite.execute(query: "INSERT INTO animal VALUES (8, 'greyhound', 'dog', 63.578, NULL, NULL);")
            try sqlite.execute(query: "INSERT INTO animal VALUES (9, 'aligator', 'reptile', 3892.75, NULL, NULL);")
            try sqlite.execute(query: "INSERT INTO animal VALUES (10, 'crocodile', 'reptile', 2987.83, NULL, NULL);")
            try sqlite.execute(query: "INSERT INTO animal VALUES (11, 'iguana', 'reptile', 39.92, NULL, NULL);")
            try sqlite.execute(query: "INSERT INTO animal VALUES (999, 'dragon', 'mythical', NULL, NULL, NULL);")
            
            return .commit
        }
        
        sqlite.lastInsertID = 0
        
        return sqlite
    }
    
    static func inMemory() -> SQLite {
        return try! SQLite(location: .memory)
    }
    
    static func prepared(query: String, configuration: ((SQLite) -> Void)? = nil) -> Statement {
        let sqlite = self.local()
        configuration?(sqlite)
        
        return try! sqlite.prepare(query: query)
    }
}
