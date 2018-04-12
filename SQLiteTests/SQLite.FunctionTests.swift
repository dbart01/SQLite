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

    // ----------------------------------
    //  MARK: - Init -
    //
    func testInitScalar() {
        let sqlite      = SQLite.default()
        let description = Function.Description(
            name:          "double",
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        XCTAssertWontThrow {
            let function = try DoubleFunction(
                sqlite:      sqlite,
                description: description
            )
//            XCTAssertEqual(function.kind,        .scalar)
            XCTAssertEqual(function.description, description)
        }
    }
    
    func testInitAggregate() {
        let sqlite      = SQLite.default()
        let description = Function.Description(
            name:          "sum",
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        XCTAssertWontThrow {
            let function = try SumFunction(
                sqlite:      sqlite,
                description: description
            )
//            XCTAssertEqual(function.kind,        .aggregate)
            XCTAssertEqual(function.description, description)
        }
    }
    
    // ----------------------------------
    //  MARK: - Execute -
    //
    func testExecute() {
        let sqlite      = SQLite.default()
        let description = Function.Description(
            name:          "abc_double",
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        let function = try! SumFunction(
            sqlite:      sqlite,
            description: description
        )
        
        try! sqlite.execute(query: "SELECT abc_double(id) as theThing FROM animal WHERE id = 10", dictionaryHandler: { result, dictionary in
            print(dictionary)
        })
        
        try! sqlite.execute(query: "SELECT abc_double(id) as theThing FROM animal WHERE id < 5", dictionaryHandler: { result, dictionary in
            print(dictionary)
        })
        
        try! sqlite.execute(query: "SELECT abc_double(id) as theThing FROM animal WHERE id = 800", dictionaryHandler: { result, dictionary in
            print(dictionary)
        })
        
        // TODO: SQLite **must** hold a strong reference to the SQLite.Function object for the pointer to the function to stay valid.
        print(function)
    }
    
    func testExecute2() {
        let sqlite      = SQLite.default()
        let description = Function.Description(
            name:          "abc_double",
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        let function = try! DoubleFunction(
            sqlite:      sqlite,
            description: description
        )
        
        try! sqlite.execute(query: "SELECT abc_double(id) as theThing FROM animal WHERE id = 10", dictionaryHandler: { result, dictionary in
            print(dictionary)
        })
        
        // TODO: SQLite **must** hold a strong reference to the SQLite.Function object for the pointer to the function to stay valid.
        print(function)
    }
    
    func testExecute3() {
        let sqlite      = SQLite.default()
        let description = Function.Description(
            name:          "abc_double",
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        let function = try! CountFunction(
            sqlite:      sqlite,
            description: description
        )
        
        try! sqlite.execute(query: "SELECT abc_double(id) as theThing FROM animal WHERE id = 10", dictionaryHandler: { result, dictionary in
            print(dictionary)
        })
        
        try! sqlite.execute(query: "SELECT abc_double(id) as theThing FROM animal WHERE id < 5", dictionaryHandler: { result, dictionary in
            print(dictionary)
        })
        
        try! sqlite.execute(query: "SELECT abc_double(id) as theThing FROM animal WHERE id = 800", dictionaryHandler: { result, dictionary in
            print(dictionary)
        })
        
        // TODO: SQLite **must** hold a strong reference to the SQLite.Function object for the pointer to the function to stay valid.
        print(function)
    }
}

// ----------------------------------
//  MARK: - Private -
//



