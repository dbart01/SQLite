//
//  DatabaseTests.swift
//  SQLite
//
//  Created by Dima Bart on 2017-05-21.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
import SQLite

class DatabaseTests: XCTestCase {
 
    private static let tempURL     = URL(fileURLWithPath: NSTemporaryDirectory())
    private static let databaseURL = DatabaseTests.tempURL.appendingPathComponent("test.sqlite")
    
    private let fileManager = FileManager.default
    
    // ----------------------------------
    //  MARK: - Setup -
    //
    override func setUp() {
        super.setUp()
        
        self.deleteDatabase()
        self.copyDatabase()
    }
    
    private func deleteDatabase() {
        do {
            try self.fileManager.removeItem(at: DatabaseTests.databaseURL)
        } catch {
            print("Failed to delete database: \(error)")
        }
    }
    
    private func copyDatabase() {
        let bundle = Bundle(for: type(of: self))
        let url    = bundle.url(forResource: "test", withExtension: "sqlite")!
        do {
            try self.fileManager.copyItem(at: url, to: DatabaseTests.databaseURL)
        } catch {
            print("Failed to copy database: \(error)")
        }
    }
    
    // ----------------------------------
    //  MARK: - Open -
    //
    func testOpenValidConnection() {
        do {
            let sqlite = try SQLite3(at: DatabaseTests.databaseURL)
            
            XCTAssertNotNil(sqlite)
            let sqliteExists = self.fileManager.fileExists(atPath: DatabaseTests.databaseURL.path)
            XCTAssertTrue(sqliteExists)
            
        } catch {
            XCTFail()
        }
    }
    
    func testOpenInvalidConnection() {
        do {
            let _ = try SQLite3(at: URL(fileURLWithPath: "/invalid.sqlite"))
            XCTFail()
        } catch Status.cantOpen {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }
    
    // ----------------------------------
    //  MARK: - Statement -
    //
    func testPrepareValidStatement() {
        let sqlite = self.openSQLite()
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
        let sqlite = self.openSQLite()
        let query  = "SELECT * FROM vehicle"
        
        do {
            let _ = try sqlite.prepare(query: query)
            XCTFail()
        } catch Status.error {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }
    
    func testParameters() {
        let query     = "SELECT * FROM animal WHERE name = :name AND type = :type"
        let statement = self.prepared(query: query)
        
        XCTAssertEqual(statement.parameterCount, 2)
        XCTAssertEqual(statement.parameterName(for: 0), ":name")
        XCTAssertEqual(statement.parameterName(for: 1), ":type")
        
        XCTAssertEqual(statement.parameterIndex(for: ":name"), 0)
        XCTAssertEqual(statement.parameterIndex(for: ":type"), 1)
    }
    
    func testInvalidParameters() {
        let query     = "SELECT * FROM animal"
        let statement = self.prepared(query: query)
        
        XCTAssertEqual(statement.parameterCount, 0)
        XCTAssertEqual(statement.parameterName(for: 0), nil)
        XCTAssertEqual(statement.parameterName(for: 1), nil)
        
        XCTAssertEqual(statement.parameterIndex(for: ":name"), nil)
        XCTAssertEqual(statement.parameterIndex(for: ":type"), nil)
    }
    
    func testBindValidParameters() {
        let query     = "SELECT * FROM animal WHERE id = ? OR name = ? OR length = ? OR image = ?"
        let statement = self.prepared(query: query)
        
        // TODO: Bind nil literal values
        
        do {
            try statement.bind(13,        column: 0)
            try statement.bind("reptile", column: 1)
            try statement.bind(261.56,    column: 2)
            try statement.bind(Data(),    column: 3)
        } catch {
            XCTFail()
        }
    }
    
    func testBindInvalidParameters() {
        let query     = "SELECT * FROM animal"
        let statement = self.prepared(query: query)
        
        do {
            try statement.bind(25, column: 0)
            XCTFail()
        } catch Status.range {
            XCTAssertTrue(true)
        } catch {
            print(error)
            XCTFail()
        }
    }
    
    // ----------------------------------
    //  MARK: - Private -
    //
    private func openSQLite() -> SQLite3 {
        return try! SQLite3(at: DatabaseTests.databaseURL)
    }
    
    private func prepared(query: String) -> Statement {
        let sqlite = self.openSQLite()
        return try! sqlite.prepare(query: query)
    }
}
