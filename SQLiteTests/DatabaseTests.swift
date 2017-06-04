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
        self.assertWillThrow(.cantOpen) {
            let _ = try SQLite3(at: URL(fileURLWithPath: "/invalid.sqlite"))
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
        
        self.assertWillThrow(.error) {
            let _ = try sqlite.prepare(query: query)
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
    
    func testBindNilParameters() {
        let query     = "SELECT * FROM animal WHERE id = ? OR name = ? OR length = ? OR image = ?"
        let statement = self.prepared(query: query)
        
        do {
            try statement.bind(integer: nil, to: 0)
            try statement.bind(string:  nil, to: 1)
            try statement.bind(double:  nil, to: 2)
            try statement.bind(blob:    nil, to: 3)
            
            let expanded = "SELECT * FROM animal WHERE id = NULL OR name = NULL OR length = NULL OR image = NULL"
            XCTAssertEqual(statement.expandedQuery, expanded)
        } catch {
            XCTFail()
        }
    }
    
    func testBindValidParameters() {
        let query     = "SELECT * FROM animal WHERE id = ? OR name = ? OR length = ? OR image = ?"
        let statement = self.prepared(query: query)
        
        do {
            try statement.bind(integer: 13,        to: 0)
            try statement.bind(string:  "reptile", to: 1)
            try statement.bind(double:  261.56,    to: 2)
            try statement.bind(blob:    Data(),    to: 3)
            
            let expanded = "SELECT * FROM animal WHERE id = 13 OR name = 'reptile' OR length = 261.56 OR image = x''"
            XCTAssertEqual(statement.expandedQuery, expanded)
            
            try statement.clearBindings()
            
            let cleared = "SELECT * FROM animal WHERE id = NULL OR name = NULL OR length = NULL OR image = NULL"
            XCTAssertEqual(statement.expandedQuery, cleared)
        } catch {
            XCTFail()
        }
    }
    
    func testBindInvalidParameters() {
        let query     = "SELECT * FROM animal"
        let statement = self.prepared(query: query)
        
        self.assertWillThrow(.range) {
            try statement.bind(integer: 25, to: 0)
        }
        
        self.assertWillThrow(.range) {
            try statement.bind(double: 25, to: 0)
        }
        
        self.assertWillThrow(.range) {
            try statement.bind(string: "25", to: 0)
        }
        
        self.assertWillThrow(.range) {
            try statement.bind(blob: Data(), to: 0)
        }
        
        self.assertWillThrow(.range) {
            try statement.bindNull(to: 0)
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
            try statement.bind(string: "hedgehog", to: 0)
            try statement.bind(string: "rodent",   to: 1)
            let result = try statement.step()
            XCTAssertEqual(result, .done)
        } catch {
            XCTFail()
        }
    }
    
    func testStepError() {
        let query     = "ROLLBACK;"
        let statement = self.prepared(query: query)
        
        self.assertWillThrow(.error) {
            _ = try statement.step()
        }
        
        self.assertWillThrow(.error) {
            try statement.reset()
        }
    }
    
    // ----------------------------------
    //  MARK: - Columns -
    //
    func testColumnCount() {
        let query     = "SELECT * FROM animal"
        let statement = self.prepared(query: query)
        
        if case .row = try! statement.step() {
            XCTAssertEqual(statement.columnCount, 6)
        } else {
            XCTFail()
        }
    }
    
    func testColumnTypes() {
        let query     = "SELECT * FROM animal WHERE id = 3"
        let statement = self.prepared(query: query)
        
        if case .row = try! statement.step() {
            XCTAssertEqual(statement.type(at: 0), .integer)
            XCTAssertEqual(statement.type(at: 1), .null)
            XCTAssertEqual(statement.type(at: 2), .text)
            XCTAssertEqual(statement.type(at: 3), .float)
            XCTAssertEqual(statement.type(at: 4), .blob)
            XCTAssertEqual(statement.type(at: 5), .null)
        } else {
            XCTFail()
        }
    }
    
    func testColumnValues() {
        let query     = "SELECT * FROM animal WHERE id = 3"
        let statement = self.prepared(query: query)
        
        if case .row = try! statement.step() {
            XCTAssertEqual(statement.integer(at: 0), 3)
            XCTAssertEqual(statement.string(at: 1),  nil)
            XCTAssertEqual(statement.string(at: 2),  "mammal")
            XCTAssertEqual(statement.double(at: 3),  4279.281)
            XCTAssertEqual(statement.blob(at: 4),    Data(bytes: [0xfe, 0xed, 0xbe, 0xef])) // feedbeef
            XCTAssertEqual(statement.blob(at: 5),    nil)
        } else {
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
    
    // ----------------------------------
    //  MARK: - Assertions -
    //
    private func assertWillThrow(_ expectedStatus: Status, _ block: () throws -> Void) {
        do {
            try block()
            XCTFail()
        } catch {
            XCTAssertEqual(error as? Status, expectedStatus)
        }
    }
}
