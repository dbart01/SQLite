//
//  PragmaRepresentableTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

import XCTest
@testable import SQLite

class PragmaRepresentableTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testInit() {
        XCTAssertEqual(Int(rawValue: 13),       13)
        XCTAssertEqual(String(rawValue: "13"), "13")
    }
    
    // ----------------------------------
    //  MARK: - Raw Value -
    //
    func testRawValue() {
        XCTAssertEqual(13.rawValue, 13)
        XCTAssertEqual("13".rawValue, "13")
    }
}
