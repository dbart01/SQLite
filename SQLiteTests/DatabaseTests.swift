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
        
        print("Database path: \(DatabaseTests.databaseURL.path)")
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
    
    // ----------------------------------
    //  MARK: - Parameters -
    //
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
            
            let expanded = "SELECT * FROM animal WHERE id = 13 OR name = 'reptile' OR length = 261.56 OR image = x''"
            XCTAssertEqual(statement.expandedQuery, expanded)
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
    //  MARK: - Step -
    //
    func testStepRow() {
        let query     = "SELECT * FROM animal"
        let statement = self.prepared(query: query)
        
        do {
            let result = try statement.step()
            XCTAssertEqual(result, .row)
        } catch {
            XCTFail()
        }
    }
    
    func testStepDone() {
        let query     = "INSERT INTO animal (name, type) VALUES (?, ?)"
        let statement = self.prepared(query: query)
        
        do {
            try statement.bind("hedgehog", column: 0)
            try statement.bind("rodent",   column: 1)
            let result = try statement.step()
            XCTAssertEqual(result, .done)
        } catch {
            XCTFail()
        }
    }
    
    func testStepError() {
        let query     = "ROLLBACK;"
        let statement = self.prepared(query: query)
        
        do {
            _ = try statement.step()
            XCTFail()
        } catch Status.error {
            XCTAssertTrue(true)
        } catch {
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
