//
//  SQLite3.LocationTests.swift
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
        XCTAssertEqual(SQLite3.Location.disk(self.url), SQLite3.Location.disk(self.url))
        XCTAssertEqual(SQLite3.Location.memory,         SQLite3.Location.memory)
        XCTAssertEqual(SQLite3.Location.temporary,      SQLite3.Location.temporary)
    }
    
    func testInequality() {
        XCTAssertNotEqual(SQLite3.Location.memory, SQLite3.Location.temporary)
    }
    
    func testPath() {
        XCTAssertEqual(SQLite3.Location.disk(self.url).path, self.url.path)
        XCTAssertEqual(SQLite3.Location.memory.path, ":memory:")
        XCTAssertEqual(SQLite3.Location.temporary.path, "")
    }
    
    
}
