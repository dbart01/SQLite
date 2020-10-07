//
//  SQLite.TransactionTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-23.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class SQLite_TransactionTests: XCTestCase {

    // MARK: - Values -

    func testValues() {
        XCTAssertEqual(SQLite.Transaction.deferred.sqlRepresentation, "DEFERRED")
        XCTAssertEqual(SQLite.Transaction.immediate.sqlRepresentation, "IMMEDIATE")
        XCTAssertEqual(SQLite.Transaction.exclusive.sqlRepresentation, "EXCLUSIVE")
    }
    
    // MARK: - Transactions -

    func testTransactionSuccessful() {
        let sqlite = SQLite.default()
        
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
        let sqlite = SQLite.default()
        
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
        let sqlite = SQLite.default()
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
