//
//  Pragma.EncodingTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class Pragma_EncodingTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - PragmaRepresentable -
    //
    func testInit() {
        XCTAssertEqual(Pragma.Encoding(rawValue: "UTF-8"),    .utf8)
        XCTAssertEqual(Pragma.Encoding(rawValue: "UTF-16"),   .utf16)
        XCTAssertEqual(Pragma.Encoding(rawValue: "UTF-16le"), .utf16le)
        XCTAssertEqual(Pragma.Encoding(rawValue: "UTF-16be"), .utf16be)
        XCTAssertEqual(Pragma.Encoding(rawValue: "UTF-32"),   nil)
    }
    
    func testRawValue() {
        XCTAssertEqual(Pragma.Encoding.utf8.rawValue,    "UTF-8")
        XCTAssertEqual(Pragma.Encoding.utf16.rawValue,   "UTF-16")
        XCTAssertEqual(Pragma.Encoding.utf16le.rawValue, "UTF-16le")
        XCTAssertEqual(Pragma.Encoding.utf16be.rawValue, "UTF-16be")
    }
    
    func testDescription() {
        XCTAssertEqual(Pragma.Encoding.utf8.sqlValue,    "'UTF-8'")
        XCTAssertEqual(Pragma.Encoding.utf16.sqlValue,   "'UTF-16'")
        XCTAssertEqual(Pragma.Encoding.utf16le.sqlValue, "'UTF-16le'")
        XCTAssertEqual(Pragma.Encoding.utf16be.sqlValue, "'UTF-16be'")
    }
}
