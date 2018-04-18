//
//  ResultSetTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-17.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class ResultSetTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testInit() {
        let resultSet = self.resultSet()
        XCTAssertNotNil(resultSet)
    }
    
    // ----------------------------------
    //  MARK: - Iteration -
    //
    func testMakeIterator() {
        let resultSet = self.resultSet()
        let iterator = resultSet.makeIterator()
        
        XCTAssertNotNil(iterator)
    }
    
    func testSingleIterate() {
        let resultSet = self.resultSet()
        
        for (index, result) in resultSet.enumerated() {
            XCTAssertEqual(result["id"] as! Int, index + 1)
        }
    }
    
    func testRepeatedIteration() {
        let resultSet = self.resultSet()
        
        for _ in 0..<10 {
            for (index, result) in resultSet.enumerated() {
                XCTAssertEqual(result["id"] as! Int, index + 1)
            }
        }
    }
    
    func testRepeatedInteruptedIteration() {
        let resultSet = self.resultSet()
        
        for iteration in 0..<10 {
            for (index, result) in resultSet.enumerated() {
                XCTAssertEqual(result["id"] as! Int, index + 1)
                if iteration == 5 && index > 5 {
                    break
                }
            }
        }
    }
    
    func testInvalidQueryIteration() {
        let sqlite    = SQLite.default()
        let statement = try! Statement(sqlite: sqlite, query: "INSERT INTO animal (id) VALUES (1)")
        let resultSet = TestResultSet(statement: statement)
        
        // First invoke a call to `next()`
        var count = 0
        for _ in resultSet {
            count += 1
        }
        
        /* ----------------------------------
         ** The first call to `next()` should
         ** error out and return nil producing
         ** no iterations.
         */
        XCTAssertEqual(count, 0)
        
        let e = self.expectation(description: "Should fail reset")
        resultSet.resetFailedHandler = {
            e.fulfill()
        }
        
        /* ---------------------------------
         ** Subsequent "make iterator" call
         ** should fail to reset statement.
         */
        for _ in resultSet {
            break
        }
        
        self.wait(for: [e], timeout: 2.0)
    }
    
    // ----------------------------------
    //  MARK: - Utilities -
    //
    private func resultSet() -> ResultSet {
        let sqlite    = SQLite.default()
        let statement = try! Statement(sqlite: sqlite, query: "SELECT * FROM animal WHERE id < 10")
        return TestResultSet(statement: statement)
    }
}

// ----------------------------------
//  MARK: - TestResultSet -
//
private class TestResultSet: ResultSet {
    
    var resetFailedHandler: (() -> Void)?
    
    override func statementResetFailed() {
        super.statementResetFailed()
        
        self.resetFailedHandler?()
    }
}
