//
//  Utilities.swift
//  SQLite
//
//  Created by Dima Bart on 2017-06-05.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
import SQLite

func XCTAssertWillThrow(_ expectedStatus: Status, _ block: () throws -> Void) {
    do {
        try block()
        XCTFail()
    } catch {
        XCTAssertEqual(error as? Status, expectedStatus)
    }
}

func XCTAssertWontThrow( _ block: () throws -> Void) {
    do {
        try block()
    } catch {
        XCTFail()
    }
}
