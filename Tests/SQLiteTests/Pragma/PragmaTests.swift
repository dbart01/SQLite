//
//  PragmaTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class PragmaTests: XCTestCase {
    
    // MARK: - Description -

    func testPragmaDescriptions() {
        XCTAssertEqual(Pragma.foreignKeys.key, "foreign_keys")
        XCTAssertTrue(Pragma.foreignKeys.type == Pragma.Boolean.self)
        
        XCTAssertEqual(Pragma.applicationID.key, "application_id")
        XCTAssertTrue(Pragma.applicationID.type == Int.self)
    }
}
