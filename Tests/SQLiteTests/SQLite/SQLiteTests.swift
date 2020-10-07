//
//  SQLiteTests.swift
//  SQLite
//
//  Created by Dima Bart on 2017-05-21.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class SQLiteTests: XCTestCase {
    
    private let fileManager = FileManager.default
    
    // MARK: - Open -

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
    
    // MARK: - Last Inserted ID -

    func testGetLastInsertedID() {
        let sqlite = SQLite.default()
        
        XCTAssertEqual(sqlite.lastInsertID, 0)
        
        let result = try! sqlite.execute(
            query: "INSERT INTO animal (id, name, type) VALUES (?, ?, ?)",
            arguments: 16, "octopus", "cephalopod"
        )
        
        XCTAssertEqual(result, .done)
        XCTAssertEqual(sqlite.lastInsertID, 16)
    }
    
    func testSetLastInsertedID() {
        let sqlite = SQLite.default()
        
        XCTAssertEqual(sqlite.lastInsertID, 0)
        
        sqlite.lastInsertID = 64
        
        XCTAssertEqual(sqlite.lastInsertID, 64)
    }
    
    // MARK: - Errors -

    func testErrorReporting() {
        let sqlite = SQLite.default()
        
        XCTAssertWillThrow(Status.error) {
            try sqlite.execute(query: "SELECT images FROM animal")
        }
        
        XCTAssertEqual(sqlite.errorStatus, .error)
        XCTAssertEqual(sqlite.errorMessage, "no such column: images")
    }
    
    // MARK: - Changes -

    func testChangeCount() {
        let sqlite = SQLite.default()
        
        XCTAssertEqual(sqlite.changeCount, 1)
        
        try! sqlite.execute(query: "DELETE FROM animal WHERE id < 10")
        
        XCTAssertEqual(sqlite.changeCount, 9)
    }
    
    func testTotalChangeCount() {
        let sqlite = SQLite.default()
        
        XCTAssertEqual(sqlite.totalChangeCount, 12)
        
        try! sqlite.execute(query: "INSERT INTO animal (id, name, type) VALUES (700, 'owl', 'bird')")
        try! sqlite.execute(query: "INSERT INTO animal (id, name, type) VALUES (701, 'hawk', 'bird')")
        
        XCTAssertEqual(sqlite.totalChangeCount, 14)
        
        try! sqlite.performTransaction {
            try sqlite.execute(query: "INSERT INTO animal (id, name, type) VALUES (702, 'eagle', 'bird')")
            try sqlite.execute(query: "INSERT INTO animal (id, name, type) VALUES (703, 'vulture', 'bird')")
            return .commit
        }
        
        XCTAssertEqual(sqlite.totalChangeCount, 16)
    }
    
    // MARK: - Metadata -

    func testMetadataWithDefaultDatabase() {
        let sqlite = SQLite.default()
        
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
        let sqlite = SQLite.default()
        
        XCTAssertWillThrow(Status.error) {
            _ = try sqlite.columnMetadataFor(column: "id", table: "animal", database: "invalid_database")
        }
    }
    
    // MARK: - Statement -

    func testPrepareValidStatement() {
        let sqlite = SQLite.default()
        let query  = "CREATE TABLE vehicle (id INTEGER primary key autoincrement, make TEXT, model TEXT);"
        
        XCTAssertWontThrow {
            let statement = try sqlite.prepare(query: query)
            XCTAssertNotNil(statement)
            XCTAssertEqual(statement.query, query)
        }
    }
    
    func testPrepareInvalidStatement() {
        let sqlite = SQLite.default()
        let query  = "SELECT * FROM vehicle"
        
        XCTAssertWillThrow(Status.error) {
            let _ = try sqlite.prepare(query: query)
        }
    }
    
    // MARK: - Statement Cache -

    func testStatementCachingEnabled() {
        let query  = "SELECT * FROM animal WHERE type = ?"
        let sqlite = SQLite.default()
        
        sqlite.isCacheEnabled = true
        
        let statement1 = try! sqlite.prepare(query: query)
        let statement2 = try! sqlite.prepare(query: query)
        
        XCTAssertTrue(statement1 === statement2)
        XCTAssertEqual(statement1.query, statement2.query)
        
        sqlite.isCacheEnabled = false
        
        let statement3 = try! sqlite.prepare(query: query)
        
        XCTAssertFalse(statement2 === statement3)
        XCTAssertEqual(statement2.query, statement3.query)
        
        /* -----------------------------------
         ** The expectation is that any cached
         ** statements should be cleared when
         ** isCachedEnabled is set to `false`.
         ** Otherwise, facilities don't exist
         ** for clearing out stale prepared
         ** statements that may be invalid.
         */
        
        sqlite.isCacheEnabled = true
        
        let statement4 = try! sqlite.prepare(query: query)
        
        XCTAssertFalse(statement2 === statement4)
        XCTAssertFalse(statement3 === statement4)
        XCTAssertEqual(statement2.query, statement4.query)
    }
    
    func testStatementCachingDisabled() {
        let query  = "SELECT * FROM animal WHERE type = ?"
        let sqlite = SQLite.default()
        
        sqlite.isCacheEnabled = false
        
        let statement1 = try! sqlite.prepare(query: query)
        let statement2 = try! sqlite.prepare(query: query)
        
        XCTAssertFalse(statement1 === statement2)
    }
    
    // MARK: - Execute -

    func testExecuteNoReturnValue() {
        let sqlite = SQLite.default()
        
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
        let sqlite = SQLite.default()
        
        var ids = [Int]()
        XCTAssertWontThrow {
            try sqlite.execute(query: "SELECT id FROM animal WHERE type = ?", arguments: "feline", rowHandler: { result, statement in
                
                XCTAssertEqual(result, .row)
                ids.append(statement.integer(at: 0))
            })
            
            XCTAssertEqual(ids, [4, 5, 6])
        }
    }
    
    // MARK: - Sequence -

    func testSequence() {
        let sqlite = SQLite.default()
        let query  = "SELECT * FROM animal where id < 10"
        
        XCTAssertWontThrow {
            let resultSet = try sqlite.sequence(for: query)
            for (index, result) in resultSet.enumerated() {
                XCTAssertEqual(result["id"] as! Int, index + 1)
            }
        }
    }
    
    // MARK: - Backup -

    func testBackup() {
        let source      = SQLite.default()
        let destination = SQLite.emptyInMemory()

        XCTAssertWontThrow {
            let backup = try source.backup(from: "temp", to: destination, database: "temp")
            
            XCTAssertTrue(backup.sourceSqlite      === source)
            XCTAssertTrue(backup.destinationSqlite === destination)
            
            XCTAssertEqual(backup.sourceName,      "temp")
            XCTAssertEqual(backup.destinationName, "temp")
        }
    }
}
