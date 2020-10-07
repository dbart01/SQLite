//
//  SQLite.FunctionTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-05.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class SQLite_FunctionTests: XCTestCase {
    
    // MARK: - Registration -

    func testRegisterType() {
        let sqlite      = SQLite.default()
        let description = Function.Description(
            name:          "xct_func",
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        XCTAssertWontThrow {
            XCTAssertEqual(sqlite.registeredFunctions.count, 0)
            
            try sqlite.register(DoubleFunction.self, using: description)
            
            XCTAssertEqual(sqlite.registeredFunctions.count, 1)
        }
        
        try! sqlite.execute(query: "SELECT xct_func(6.5) as result", dictionaryHandler: { result, dictionary in
            XCTAssertEqual(dictionary["result"] as! Double, 13)
        })
    }
    
    func testRegisterFunction() {
        let sqlite      = SQLite.default()
        let description = Function.Description(
            name:          "xct_func",
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        let function = try! DoubleFunction(
            sqlite:      sqlite,
            description: description
        )
        
        XCTAssertWontThrow {
            XCTAssertEqual(sqlite.registeredFunctions.count, 0)
            
            sqlite.register(function)
            
            XCTAssertEqual(sqlite.registeredFunctions.count, 1)
        }
        
        try! sqlite.execute(query: "SELECT xct_func(6.5) as result", dictionaryHandler: { result, dictionary in
            XCTAssertEqual(dictionary["result"] as! Double, 13)
        })
    }
    
    func testUnregister() {
        let sqlite      = SQLite.default()
        let description = Function.Description(
            name:          "xct_func",
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        try! sqlite.register(DoubleFunction.self, using: description)
        
        XCTAssertEqual(sqlite.registeredFunctions.count, 1)
        sqlite.unregister(functionMatching: description)
        XCTAssertEqual(sqlite.registeredFunctions.count, 0)
        
        XCTAssertWillThrow(Status.error) {
            try sqlite.execute(query: "SELECT xct_func(6.5) as result", dictionaryHandler: { result, dictionary in
                XCTAssertEqual(dictionary["result"] as! Double, 13)
            })
        }
    }
}
