//
//  SQLiteTests.swift
//  SQLite
//
//  Created by Dima Bart on 2017-05-21.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
import SQLite

class SQLiteTests: XCTestCase {
    
    private let fileManager = FileManager.default
    
    // ----------------------------------
    //  MARK: - Open -
    //
    func testOpenValidConnection() {
        XCTAssertWontThrow {
            let localURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test.sqlite")
            try? self.fileManager.removeItem(at: localURL)
            
            let sqlite = try SQLite(location: .disk(localURL))
            
            XCTAssertNotNil(sqlite)
            let sqliteExists = self.fileManager.fileExists(atPath: localURL.path)
            XCTAssertTrue(sqliteExists)
        }
    }
    
    func testOpenInvalidConnection() {
        XCTAssertWillThrow(Status.cantOpen) {
            let url = URL(fileURLWithPath: "/invalid.sqlite")
            let _   = try SQLite(location: .disk(url))
        }
    }
    
    // ----------------------------------
    //  MARK: - Last Inserted ID -
    //
    func testGetLastInsertedID() {
        let sqlite = SQLite.local()
        
        XCTAssertEqual(sqlite.lastInsertID, 0)
        
        let result = try! sqlite.execute(
            query: "INSERT INTO animal (id, name, type) VALUES (?, ?, ?)",
            arguments: 16, "octopus", "cephalopod"
        )
        
        XCTAssertEqual(result, .done)
        XCTAssertEqual(sqlite.lastInsertID, 16)
    }
    
    func testSetLastInsertedID() {
        let sqlite = SQLite.local()
        
        XCTAssertEqual(sqlite.lastInsertID, 0)
        
        sqlite.lastInsertID = 64
        
        XCTAssertEqual(sqlite.lastInsertID, 64)
    }
    
    // ----------------------------------
    //  MARK: - Metadata -
    //
    func testMetadataWithDefaultDatabase() {
        let sqlite = SQLite.local()
        
        XCTAssertWontThrow {
            let columns  = ["id", "name", "type", "length", "image", "thumb"]
            let expected = [
                ColumnMetadata(type: "INTEGER", collation: "BINARY", isNotNull: false, isPrimaryKey: true,  isAutoIncrement: true),
                ColumnMetadata(type: "TEXT",    collation: "BINARY", isNotNull: false, isPrimaryKey: false, isAutoIncrement: false),
                ColumnMetadata(type: "TEXT",    collation: "BINARY", isNotNull: false, isPrimaryKey: false, isAutoIncrement: false),
                ColumnMetadata(type: "REAL",    collation: "BINARY", isNotNull: false, isPrimaryKey: false, isAutoIncrement: false),
                ColumnMetadata(type: "BLOB",    collation: "BINARY", isNotNull: false, isPrimaryKey: false, isAutoIncrement: false),
                ColumnMetadata(type: "BLOB",    collation: "BINARY", isNotNull: false, isPrimaryKey: false, isAutoIncrement: false),
            ]
            
            for (index, column) in columns.enumerated() {
                let metadata = try sqlite.columnMetadataFor(column: column, table: "animal")
                XCTAssertEqual(metadata, expected[index])
            }
            
        }
    }
    
    func testMetadataWithInvalidDatabase() {
        let sqlite = SQLite.local()
        
        XCTAssertWillThrow(Status.error) {
            _ = try sqlite.columnMetadataFor(column: "id", table: "animal", database: "invalid_database")
        }
    }
    
    // ----------------------------------
    //  MARK: - Statement -
    //
    func testPrepareValidStatement() {
        let sqlite = SQLite.local()
        let query  = "CREATE TABLE vehicle (id INTEGER primary key autoincrement, make TEXT, model TEXT);"
        
        XCTAssertWontThrow {
            let statement = try sqlite.prepare(query: query)
            XCTAssertNotNil(statement)
            XCTAssertEqual(statement.query, query)
        }
    }
    
    func testPrepareInvalidStatement() {
        let sqlite = SQLite.local()
        let query  = "SELECT * FROM vehicle"
        
        XCTAssertWillThrow(Status.error) {
            let _ = try sqlite.prepare(query: query)
        }
    }
    
    // ----------------------------------
    //  MARK: - Statement Cache -
    //
    func testStatementCachingEnabled() {
        let query  = "SELECT * FROM animal WHERE type = ?"
        let sqlite = SQLite.local()
        
        sqlite.isCacheEnabled = true
        
        let statement1 = try! sqlite.prepare(query: query)
        try! statement1.bind(string: "feline", to: 0)
        try! statement1.step()
        
        XCTAssertTrue(statement1.isBusy)
        
        let statement1Query = statement1.expandedQuery
        
        let statement2      = try! sqlite.prepare(query: query)
        let statement2Query = statement2.expandedQuery
        
        XCTAssertFalse(statement2.isBusy)
        XCTAssertTrue(statement1 === statement2)
        XCTAssertNotEqual(statement1Query, statement2Query)
    }
    
    func testStatementCachingDisabled() {
        let query  = "SELECT * FROM animal WHERE type = ?"
        let sqlite = SQLite.local()
        
        sqlite.isCacheEnabled = false
        
        let statement1 = try! sqlite.prepare(query: query)
        let statement2 = try! sqlite.prepare(query: query)
        
        XCTAssertFalse(statement1 === statement2)
    }
    
    // ----------------------------------
    //  MARK: - Execute -
    //
    func testExecuteNoReturnValue() {
        let sqlite = SQLite.local()
        
        XCTAssertWontThrow {
            let result = try sqlite.execute(query: "INSERT INTO animal (id, name, type) VALUES (?, ?, ?)", arguments: 99, "dragon", "mythical")
            
            XCTAssertEqual(result, .done)
            
            var results = 0
            try sqlite.execute(query: "SELECT id, name, type FROM animal WHERE id = ?", arguments: 99, dictionaryHandler: { result, dictionary in
                XCTAssertEqual(dictionary["id"]   as! Int,    99)
                XCTAssertEqual(dictionary["name"] as! String, "dragon")
                XCTAssertEqual(dictionary["type"] as! String, "mythical")
                results += 1
            })
            
            XCTAssertEqual(results, 1)
        }
    }
    
    func testExecuteRows() {
        let sqlite = SQLite.local()
        
        var ids = [Int]()
        XCTAssertWontThrow {
            try sqlite.execute(query: "SELECT id FROM animal WHERE type = ?", arguments: "feline", rowHandler: { result, statement in
                
                XCTAssertEqual(result, .row)
                ids.append(statement.integer(at: 0))
            })
            
            XCTAssertEqual(ids, [4, 5, 6])
        }
    }
    
    // ----------------------------------
    //  MARK: - Transactions -
    //
    func testTransactionSuccessful() {
        let sqlite = SQLite.local()
        
        let dragons = [
            "dragon-transaction-1",
            "dragon-transaction-2",
            "dragon-transaction-3",
            "dragon-transaction-4",
        ]
        
        XCTAssertWontThrow {
            let result = try sqlite.performTransaction(.deferred) {
                try dragons.forEach { dragon in
                    try sqlite.execute(query: "INSERT INTO animal (name, type) VALUES (?, ?)", arguments: dragon, "mythical")
                }
                return .commit
            }
            
            XCTAssertEqual(result, .commit)
            
            var results = 0
            try sqlite.execute(query: "SELECT * FROM animal WHERE name LIKE 'dragon-transaction-%' ORDER BY id") { (result, dictionary: [String: Any]) in
                XCTAssertEqual(dragons[results], dictionary["name"] as! String)
                results += 1
            }
            XCTAssertEqual(results, 4)
        }
    }
    
    func testTransactionThrowing() {
        let sqlite = SQLite.local()
        
        XCTAssertWillThrow(Status.constraint) {
            try sqlite.performTransaction(.deferred) {
                /* -----------------------------------
                 ** id = 1 should already exist, we're
                 ** counting on this insert to fail.
                 */
                try sqlite.execute(query: "INSERT INTO animal (id, name, type) VALUES (?, ?, ?)", arguments: 1, "dragon", "mythical")
                return .commit
            }
        }
    }
    
    func testTransactionExplicitRollback() {
        let sqlite = SQLite.local()
        let name   = "mythical-magical-unicorn"
        
        XCTAssertWontThrow {
            let result = try sqlite.performTransaction(.deferred) {
                /* -----------------------------------
                 ** id = 1 should already exist, we're
                 ** counting on this insert to fail.
                 */
                try sqlite.execute(query: "INSERT INTO animal (name, type) VALUES (?, ?)", arguments: name, "mythical")
                return .rollback
            }
            
            XCTAssertEqual(result, .rollback)
            
            var results = 0
            try sqlite.execute(query: "SELECT * FROM animal WHERE name = ?", arguments: name) { (result, dictionary: [String: Any]) in
                results += 1
            }
            XCTAssertEqual(results, 0)
        }
    }
}
