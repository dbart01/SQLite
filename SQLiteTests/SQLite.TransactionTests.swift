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

    func testValues() {
        XCTAssertEqual(SQLite.Transaction.deferred.sqlRepresentation, "DEFERRED")
        XCTAssertEqual(SQLite.Transaction.immediate.sqlRepresentation, "IMMEDIATE")
        XCTAssertEqual(SQLite.Transaction.exclusive.sqlRepresentation, "EXCLUSIVE")
    }
}
