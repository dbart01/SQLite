//
//  SQLite3.TransactionTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-23.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class SQLite_TransactionTests: XCTestCase {

    func testValues() {
        XCTAssertEqual(SQLite3.Transaction.deferred.sqlRepresentation, "DEFERRED")
        XCTAssertEqual(SQLite3.Transaction.immediate.sqlRepresentation, "IMMEDIATE")
        XCTAssertEqual(SQLite3.Transaction.exclusive.sqlRepresentation, "EXCLUSIVE")
    }
}
