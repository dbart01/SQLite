//
//  FunctionTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-10.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class FunctionTests: XCTestCase {
    
    // MARK: - Init -

    func testInit() {
        let sqlite      = SQLite.default()
        let description = Function.Description(
            name:          "xct_is_large",
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        XCTAssertWontThrow {
            let function = try Function(sqlite: sqlite, description: description)
            XCTAssertTrue(function.sqlite === sqlite)
            XCTAssertEqual(function.description, description)
        }
    }
}
