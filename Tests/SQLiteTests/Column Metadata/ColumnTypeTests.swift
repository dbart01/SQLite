//
//  ColumnTypeTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2017-06-07.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
import sqlite3
@testable import SQLite

class ColumnTypeTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Init -
    //
    func testValidColumnTypes() {
        XCTAssertEqual(ColumnType(type: SQLITE_INTEGER), .integer)
        XCTAssertEqual(ColumnType(type: SQLITE_FLOAT),   .float)
        XCTAssertEqual(ColumnType(type: SQLITE_TEXT),    .text)
        XCTAssertEqual(ColumnType(type: SQLITE_BLOB),    .blob)
        XCTAssertEqual(ColumnType(type: SQLITE_NULL),    .null)
    }
    
    func testInvalidColumnTypes() {
        XCTAssertNil(ColumnType(type: 123))
        XCTAssertNil(ColumnType(type: 234))
    }
    
    // ----------------------------------
    //  MARK: - Conversion -
    //
    func testColumnTypeFromInt() {
        let type = SQLITE_FLOAT
        XCTAssertEqual(type.columnType, .float)
    }
}
