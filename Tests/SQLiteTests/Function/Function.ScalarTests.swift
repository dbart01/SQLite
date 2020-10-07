//
//  Function.ScalarTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-10.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class Function_ScalarTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Scalar -
    //
    func testScalar() {
        let sqlite      = SQLite.default()
        let description = Function.Description(
            name:          "xct_double",
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        XCTAssertWontThrow {
            let function = try DoubleFunction(sqlite: sqlite, description: description)
            
            try sqlite.execute(query: "SELECT xct_double(3) as result", dictionaryHandler: { result, dictionary in
                XCTAssertEqual(dictionary["result"] as! Double, 6.0)
            })
            
            _ = function.description
        }
    }
    
    // ----------------------------------
    //  MARK: - Invalid -
    //
    func testScalarInvalid() {
        let sqlite      = SQLite.default()
        let description = Function.Description(
            name:          String.ultraLongName,
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        XCTAssertWillThrow(Status.misuse) {
            _ = try DoubleFunction(sqlite: sqlite, description: description)
        }
    }
}
