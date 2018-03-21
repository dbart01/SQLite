//
//  SQLite+ExecuteTests.swift
//  SQLite
//
//  Created by Dima Bart on 2017-06-05.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
import SQLite

class SQLite_ExecuteTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Execute -
    //
    func testExecute() {
        let sqlite = SQLite3.local()
        
        var ids = [Int]()
        XCTAssertWontThrow {
            let result = try sqlite.execute(query: "SELECT id FROM animal WHERE type = ?", arguments: "feline") { statement in
                
                ids.append(statement.integer(at: 0))
            }
            
            XCTAssertEqual(result, .done)
            XCTAssertEqual(ids, [4, 5, 6])            
        }
    }
}
