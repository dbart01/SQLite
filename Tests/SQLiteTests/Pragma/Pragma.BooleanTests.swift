//
//  Pragma.BooleanTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class Pragma_BooleanTests: XCTestCase {

    // MARK: - PragmaRepresentable -

    func testInit() {
        XCTAssertEqual(Pragma.Boolean(rawValue: 1), .on)
        XCTAssertEqual(Pragma.Boolean(rawValue: 0), .off)
        XCTAssertEqual(Pragma.Boolean(rawValue: 5), nil)
    }
    
    func testRawValue() {
        XCTAssertEqual(Pragma.Boolean.on.rawValue,  1)
        XCTAssertEqual(Pragma.Boolean.off.rawValue, 0)
    }
    
    func testDescription() {
        XCTAssertEqual(Pragma.Boolean.on.sqlValue,  "ON")
        XCTAssertEqual(Pragma.Boolean.off.sqlValue, "OFF")
    }
}
