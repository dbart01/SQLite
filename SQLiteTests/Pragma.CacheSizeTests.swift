//
//  Pragma.CacheSizeTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class Pragma_PageSizeTests: XCTestCase {

    // ----------------------------------
    //  MARK: - PragmaRepresentable -
    //
    func testInit() {
        XCTAssertEqual(Pragma.CacheSize(rawValue: 200),   .pages(200))
        XCTAssertEqual(Pragma.CacheSize(rawValue: -1024), .kilobytes(1024))
    }
    
    func testRawValue() {
        XCTAssertEqual(Pragma.CacheSize.pages(200).rawValue,      200)
        XCTAssertEqual(Pragma.CacheSize.kilobytes(1024).rawValue, -1024)
    }
    
    func testDescription() {
        XCTAssertEqual(Pragma.CacheSize.pages(200).sqlValue,      "200")
        XCTAssertEqual(Pragma.CacheSize.kilobytes(1024).sqlValue, "-1024")
    }
    
    // ----------------------------------
    //  MARK: - Equality -
    //
    func testEquality() {
        XCTAssertEqual(Pragma.CacheSize.pages(200),    Pragma.CacheSize.pages(200))
        XCTAssertNotEqual(Pragma.CacheSize.pages(200), Pragma.CacheSize.pages(100))
        
        XCTAssertEqual(Pragma.CacheSize.kilobytes(1024),    Pragma.CacheSize.kilobytes(1024))
        XCTAssertNotEqual(Pragma.CacheSize.kilobytes(1024), Pragma.CacheSize.kilobytes(2048))
    }
}
