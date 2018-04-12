//
//  Function.ArgCountTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-10.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class Function_ArgCountTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Values -
    //
    func testIntegerValue() {
        XCTAssertEqual(Function.ArgCount.infinite.integerValue,  -1)
        XCTAssertEqual(Function.ArgCount.none.integerValue,       0)
        XCTAssertEqual(Function.ArgCount.finite(12).integerValue, 12)
    }
}
