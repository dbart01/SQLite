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
        
        print("Database path: \(DatabaseURL.path)")
    }
    
    private func deleteDatabase() {
        do {
            try self.fileManager.removeItem(at: DatabaseURL)
        } catch {
            print("Failed to delete database: \(error)")
        }
    }
    
    private func copyDatabase() {
        let bundle = Bundle(for: type(of: self))
        let url    = bundle.url(forResource: "test", withExtension: "sqlite")!
        do {
            try self.fileManager.copyItem(at: url, to: DatabaseURL)
        } catch {
            print("Failed to copy database: \(error)")
        }
    }
    
    // ----------------------------------
    //  MARK: - Open -
    //
    func testOpenValidConnection() {
        do {
            let sqlite = try SQLite3(at: DatabaseURL)
            
            XCTAssertNotNil(sqlite)
            let sqliteExists = self.fileManager.fileExists(atPath: DatabaseURL.path)
            XCTAssertTrue(sqliteExists)
            
        } catch {
            XCTFail()
        }
    }
    
    func testOpenInvalidConnection() {
        XCTAssertWillThrow(.cantOpen) {
            let _ = try SQLite3(at: URL(fileURLWithPath: "/invalid.sqlite"))
        }
    }
    
    // ----------------------------------
    //  MARK: - Statement -
    //
    func testPrepareValidStatement() {
        let sqlite = openSQLite()
        let query  = "CREATE TABLE vehicle (id INTEGER primary key autoincrement, make TEXT, model TEXT);"
        
        do {
            let statement = try sqlite.prepare(query: query)
            XCTAssertNotNil(statement)
            XCTAssertEqual(statement.query, query)
        } catch {
            XCTFail()
        }
    }
    
    func testPrepareInvalidStatement() {
        let sqlite = openSQLite()
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
        let sqlite = openSQLite()
        
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
        let sqlite = openSQLite()
        
        sqlite.isCacheEnabled = false
        
        let statement1 = try! sqlite.prepare(query: query)
        let statement2 = try! sqlite.prepare(query: query)
        
        XCTAssertFalse(statement1 === statement2)
    }
}
