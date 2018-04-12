//
//  Function.DescriptionTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-10.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class Function_DescriptionTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Init -
    //
    func testInit() {
        let description = Function.Description(
            name:          "count",
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: false
        )
        
        XCTAssertEqual(description.name,          "count")
        XCTAssertEqual(description.arguments,     .finite(1))
        XCTAssertEqual(description.encoding,      .utf8)
        XCTAssertEqual(description.deterministic, false)
    }
    
    func testDefaultToDeterministic() {
        let description = Function.Description(
            name:      "count",
            arguments: .finite(1),
            encoding:  .utf8
        )
        
        XCTAssertEqual(description.deterministic, true)
    }
}
