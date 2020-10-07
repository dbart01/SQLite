//
//  Function.AggregateTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-10.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class Function_AggregateTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Aggregate Reference -
    //
    func testAggregateWithReferenceContainer() {
        let sqlite      = SQLite.default()
        let description = Function.Description(
            name:          "xct_sum",
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        XCTAssertWontThrow {
            let function = try SumFunction(sqlite: sqlite, description: description)
            
            try sqlite.execute(query: "SELECT xct_sum(id) as result FROM animal WHERE id < 20", dictionaryHandler: { result, dictionary in
                XCTAssertEqual(dictionary["result"] as! Int, 66)
            })
            
            _ = function.description
        }
    }
    
    func testAggregateWithInt() {
        let sqlite      = SQLite.default()
        let description = Function.Description(
            name:          "xct_count",
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        XCTAssertWontThrow {
            let function = try CountFunction(sqlite: sqlite, description: description)
            
            try sqlite.execute(query: "SELECT xct_count(id) as result FROM animal WHERE id < 20", dictionaryHandler: { result, dictionary in
                XCTAssertEqual(dictionary["result"] as! Int, 11)
            })
            
            _ = function.description
        }
    }
    
    func testAggregateWithString() {
        let sqlite      = SQLite.default()
        let description = Function.Description(
            name:          "xct_concat",
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        XCTAssertWontThrow {
            let function = try ConcatFunction(sqlite: sqlite, description: description)
            
            try sqlite.execute(query: "SELECT xct_concat(id) as result FROM animal WHERE id < 20", dictionaryHandler: { result, dictionary in
                XCTAssertEqual(dictionary["result"] as! String, "1234567891011")
            })
            
            _ = function.description
        }
    }
    
    // ----------------------------------
    //  MARK: - Invalid -
    //
    func testAggregateInvalid() {
        let sqlite      = SQLite.default()
        let description = Function.Description(
            name:          String.ultraLongName,
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        XCTAssertWillThrow(Status.misuse) {
            _ = try ConcatFunction(sqlite: sqlite, description: description)
        }
    }
}

