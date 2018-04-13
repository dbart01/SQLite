//
//  SQLite.LocationTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-20.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class SQLite_LocationTests: XCTestCase {

    private let url = URL(fileURLWithPath: "/some/path")
    
    func testEquality() {
        XCTAssertEqual(SQLite.Location.disk(self.url), SQLite.Location.disk(self.url))
        XCTAssertEqual(SQLite.Location.memory,         SQLite.Location.memory)
        XCTAssertEqual(SQLite.Location.temporary,      SQLite.Location.temporary)
    }
    
    func testInequality() {
        XCTAssertNotEqual(SQLite.Location.memory, SQLite.Location.temporary)
    }
    
    func testPath() {
        XCTAssertEqual(SQLite.Location.disk(self.url).path, self.url.path)
        XCTAssertEqual(SQLite.Location.memory.path, ":memory:")
        XCTAssertEqual(SQLite.Location.temporary.path, "")
    }
    
    
}
