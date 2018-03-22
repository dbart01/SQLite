//
//  Utilities.swift
//  SQLite
//
//  Created by Dima Bart on 2017-06-05.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
import SQLite

func XCTAssertWillThrow<T>(_ expectedError: T, _ block: () throws -> Void) where T: Error, T: Equatable {
    do {
        try block()
        XCTFail()
    } catch {
        XCTAssertEqual(error as? T, expectedError)
    }
}

func XCTAssertWontThrow( _ block: () throws -> Void) {
    do {
        try block()
    } catch {
        XCTFail()
    }
}
