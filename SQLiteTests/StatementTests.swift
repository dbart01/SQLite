//
//  StatementTests.swift
//  SQLite
//
//  Created by Dima Bart on 2017-06-05.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
import SQLite

class StatementTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - State -
    //
    func testIsBusy() {
        let statement = prepared(query: "SELECT * FROM animal")
        
        XCTAssertFalse(statement.isBusy)
        
        try! statement.step()
        
        XCTAssertTrue(statement.isBusy)
    }
    
    func testIsReadOnly() {
        let statement1 = prepared(query: "SELECT * FROM animal")
        XCTAssertTrue(statement1.isReadOnly)
        
        let statement2 = prepared(query: "UPDATE animal SET name = 'dog' WHERE id = 3")
        XCTAssertFalse(statement2.isReadOnly)
    }

    // ----------------------------------
    //  MARK: - Parameters -
    //
    func testParameters() {
        let query     = "SELECT * FROM animal WHERE name = :name AND type = :type"
        let statement = prepared(query: query)
        
        XCTAssertEqual(statement.parameterCount, 2)
        XCTAssertEqual(statement.parameterName(for: 0), ":name")
        XCTAssertEqual(statement.parameterName(for: 1), ":type")
        
        XCTAssertEqual(statement.parameterIndex(for: ":name"), 0)
        XCTAssertEqual(statement.parameterIndex(for: ":type"), 1)
    }
    
    func testInvalidParameters() {
        let query     = "SELECT * FROM animal"
        let statement = prepared(query: query)
        
        XCTAssertEqual(statement.parameterCount, 0)
        XCTAssertEqual(statement.parameterName(for: 0), nil)
        XCTAssertEqual(statement.parameterName(for: 1), nil)
        
        XCTAssertEqual(statement.parameterIndex(for: ":name"), nil)
        XCTAssertEqual(statement.parameterIndex(for: ":type"), nil)
    }
    
    func testBindNilParameters() {
        let query     = "SELECT * FROM animal WHERE id = ? OR name = ? OR length = ? OR image = ?"
        let expanded  = "SELECT * FROM animal WHERE id = NULL OR name = NULL OR length = NULL OR image = NULL"
        let statement = prepared(query: query)
        
        do {
            try statement.bind(integer: nil, to: 0)
            try statement.bind(string:  nil, to: 1)
            try statement.bind(double:  nil, to: 2)
            try statement.bind(blob:    nil, to: 3)
            
            XCTAssertEqual(statement.expandedQuery, expanded)
            XCTAssertEqual(statement.query, query)
        } catch {
            XCTFail()
        }
    }
    
    func testBindValidParameters() {
        let query     = "SELECT * FROM animal WHERE id = ? OR name = ? OR length = ? OR image = ?"
        let statement = prepared(query: query)
        
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
            XCTAssertEqual(statement.query, query)
        } catch {
            XCTFail()
        }
    }
    
    func testBindInvalidParameters() {
        let query     = "SELECT * FROM animal"
        let statement = prepared(query: query)
        
        XCTAssertWillThrow(.range) {
            try statement.bind(integer: 25, to: 0)
        }
        
        XCTAssertWillThrow(.range) {
            try statement.bind(double: 25, to: 0)
        }
        
        XCTAssertWillThrow(.range) {
            try statement.bind(string: "25", to: 0)
        }
        
        XCTAssertWillThrow(.range) {
            try statement.bind(blob: Data(), to: 0)
        }
        
        XCTAssertWillThrow(.range) {
            try statement.bindNull(to: 0)
        }
    }
    
    // ----------------------------------
    //  MARK: - Step -
    //
    func testStepRow() {
        let query     = "SELECT * FROM animal"
        let statement = prepared(query: query)
        
        do {
            let result = try statement.step()
            XCTAssertEqual(result, .row)
        } catch {
            XCTFail()
        }
    }
    
    func testStepDone() {
        let query     = "INSERT INTO animal (name, type) VALUES (?, ?)"
        let statement = prepared(query: query)
        
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
        let statement = prepared(query: query)
        
        XCTAssertWillThrow(.error) {
            _ = try statement.step()
        }
        
        XCTAssertWillThrow(.error) {
            try statement.reset()
        }
    }

    // ----------------------------------
    //  MARK: - Columns -
    //
    func testColumnCount() {
        let query     = "SELECT * FROM animal"
        let statement = prepared(query: query)
        
        if case .row = try! statement.step() {
            XCTAssertEqual(statement.columnCount, 6)
        } else {
            XCTFail()
        }
    }
    
    func testColumnNames() {
        let query     = "SELECT * FROM animal WHERE id = 3"
        let statement = prepared(query: query)
        
        if case .row = try! statement.step() {
            XCTAssertEqual(statement.columnName(at: 0), "id")
            XCTAssertEqual(statement.columnName(at: 1), "name")
            XCTAssertEqual(statement.columnName(at: 2), "type")
            XCTAssertEqual(statement.columnName(at: 3), "length")
            XCTAssertEqual(statement.columnName(at: 4), "image")
            XCTAssertEqual(statement.columnName(at: 5), "thumb")
        } else {
            XCTFail()
        }
    }
    
    func testColumnTypes() {
        let query     = "SELECT * FROM animal WHERE id = 3"
        let statement = prepared(query: query)
        
        if case .row = try! statement.step() {
            XCTAssertEqual(statement.columnType(at: 0), .integer)
            XCTAssertEqual(statement.columnType(at: 1), .null)
            XCTAssertEqual(statement.columnType(at: 2), .text)
            XCTAssertEqual(statement.columnType(at: 3), .float)
            XCTAssertEqual(statement.columnType(at: 4), .blob)
            XCTAssertEqual(statement.columnType(at: 5), .null)
        } else {
            XCTFail()
        }
    }
    
    func testColumnValues() {
        let query     = "SELECT * FROM animal WHERE id = 3"
        let statement = prepared(query: query)
        
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
}
