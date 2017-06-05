//
//  Utilities.swift
//  SQLite
//
//  Created by Dima Bart on 2017-06-05.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
import SQLite

internal let TempURL     = URL(fileURLWithPath: NSTemporaryDirectory())
internal let DatabaseURL = TempURL.appendingPathComponent("test.sqlite")

internal func openSQLite() -> SQLite3 {
    return try! SQLite3(at: DatabaseURL)
}

internal func prepared(query: String, configuration: ((SQLite3) -> Void)? = nil) -> Statement {
    let sqlite = openSQLite()
    configuration?(sqlite)
    
    return try! sqlite.prepare(query: query)
}

// ----------------------------------
//  MARK: - Assertions -
//
internal func XCTAssertWillThrow(_ expectedStatus: Status, _ block: () throws -> Void) {
    do {
        try block()
        XCTFail()
    } catch {
        XCTAssertEqual(error as? Status, expectedStatus)
    }
}
