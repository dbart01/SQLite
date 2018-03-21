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
    //  MARK: - Setup -
    //
    override func setUp() {
        super.setUp()
        
        self.deleteDatabase()
        self.copyDatabase()
        
        print("Database path: \(SQLite3.localURL.path)")
    }
    
    private func deleteDatabase() {
        do {
            try self.fileManager.removeItem(at: SQLite3.localURL)
        } catch {
            print("Failed to delete database: \(error)")
        }
    }
    
    private func copyDatabase() {
        let bundle = Bundle(for: type(of: self))
        let url    = bundle.url(forResource: "test", withExtension: "sqlite")!
        do {
            try self.fileManager.copyItem(at: url, to: SQLite3.localURL)
        } catch {
            print("Failed to copy database: \(error)")
        }
    }
    
    // ----------------------------------
    //  MARK: - Open -
    //
    func testOpenValidConnection() {
        XCTAssertWontThrow {
            let sqlite = try SQLite3(location: .disk(SQLite3.localURL))
            
            XCTAssertNotNil(sqlite)
            let sqliteExists = self.fileManager.fileExists(atPath: SQLite3.localURL.path)
            XCTAssertTrue(sqliteExists)
        }
    }
    
    func testOpenInvalidConnection() {
        XCTAssertWillThrow(.cantOpen) {
            let url = URL(fileURLWithPath: "/invalid.sqlite")
            let _   = try SQLite3(location: .disk(url))
        }
    }
    
    // ----------------------------------
    //  MARK: - Last Inserted ID -
    //
    func testGetLastInsertedID() {
        let sqlite = SQLite3.local()
        
        XCTAssertEqual(sqlite.lastInsertID, 0)
        
        let result = try! sqlite.execute(
            query: "INSERT INTO animal (id, name, type) VALUES (?, ?, ?)",
            arguments: 16, "octopus", "cephalopod"
        )
        
        XCTAssertEqual(result, .done)
        XCTAssertEqual(sqlite.lastInsertID, 16)
    }
    
    func testSetLastInsertedID() {
        let sqlite = SQLite3.local()
        
        XCTAssertEqual(sqlite.lastInsertID, 0)
        
        sqlite.lastInsertID = 64
        
        XCTAssertEqual(sqlite.lastInsertID, 64)
    }
    
    // ----------------------------------
    //  MARK: - Metadata -
    //
    func testMetadataWithDefaultDatabase() {
        let sqlite = SQLite3.local()
        
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
        let sqlite = SQLite3.local()
        
        XCTAssertWillThrow(.error) {
            _ = try sqlite.columnMetadataFor(column: "id", table: "animal", database: "invalid_database")
        }
    }
    
    // ----------------------------------
    //  MARK: - Statement -
    //
    func testPrepareValidStatement() {
        let sqlite = SQLite3.local()
        let query  = "CREATE TABLE vehicle (id INTEGER primary key autoincrement, make TEXT, model TEXT);"
        
        XCTAssertWontThrow {
            let statement = try sqlite.prepare(query: query)
            XCTAssertNotNil(statement)
            XCTAssertEqual(statement.query, query)
        }
    }
    
    func testPrepareInvalidStatement() {
        let sqlite = SQLite3.local()
        let query  = "SELECT * FROM vehicle"
        
        XCTAssertWillThrow(.error) {
            let _ = try sqlite.prepare(query: query)
        }
    }
    
    // ----------------------------------
    //  MARK: - Statement Cache -
    //
    func testStatementCachingEnabled() {
        let query  = "SELECT * FROM animal WHERE type = ?"
        let sqlite = SQLite3.local()
        
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
        let sqlite = SQLite3.local()
        
        sqlite.isCacheEnabled = false
        
        let statement1 = try! sqlite.prepare(query: query)
        let statement2 = try! sqlite.prepare(query: query)
        
        XCTAssertFalse(statement1 === statement2)
    }
}
