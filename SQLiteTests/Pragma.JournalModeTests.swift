//
//  Pragma.JournalModeTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-27.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class Pragma_JournalModeTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - PragmaRepresentable -
    //
    func testInit() {
        XCTAssertEqual(Pragma.JournalMode(rawValue: "OFF"),      .off)
        XCTAssertEqual(Pragma.JournalMode(rawValue: "DELETE"),   .delete)
        XCTAssertEqual(Pragma.JournalMode(rawValue: "TRUNCATE"), .truncate)
        XCTAssertEqual(Pragma.JournalMode(rawValue: "PERSIST"),  .persist)
        XCTAssertEqual(Pragma.JournalMode(rawValue: "MEMORY"),   .memory)
        XCTAssertEqual(Pragma.JournalMode(rawValue: "WAL"),      .wal)
        
        XCTAssertEqual(Pragma.JournalMode(rawValue: "off"),      .off)
        XCTAssertEqual(Pragma.JournalMode(rawValue: "delete"),   .delete)
        XCTAssertEqual(Pragma.JournalMode(rawValue: "truncate"), .truncate)
        XCTAssertEqual(Pragma.JournalMode(rawValue: "persist"),  .persist)
        XCTAssertEqual(Pragma.JournalMode(rawValue: "memory"),   .memory)
        XCTAssertEqual(Pragma.JournalMode(rawValue: "wal"),      .wal)
        
        XCTAssertEqual(Pragma.JournalMode(rawValue: "INVALID"),  nil)
    }
    
    func testRawValue() {
        XCTAssertEqual(Pragma.JournalMode.off.rawValue,      "OFF")
        XCTAssertEqual(Pragma.JournalMode.delete.rawValue,   "DELETE")
        XCTAssertEqual(Pragma.JournalMode.truncate.rawValue, "TRUNCATE")
        XCTAssertEqual(Pragma.JournalMode.persist.rawValue,  "PERSIST")
        XCTAssertEqual(Pragma.JournalMode.memory.rawValue,   "MEMORY")
        XCTAssertEqual(Pragma.JournalMode.wal.rawValue,      "WAL")
    }
    
    func testDescription() {
        XCTAssertEqual(Pragma.JournalMode.off.sqlValue,      "OFF")
        XCTAssertEqual(Pragma.JournalMode.delete.sqlValue,   "DELETE")
        XCTAssertEqual(Pragma.JournalMode.truncate.sqlValue, "TRUNCATE")
        XCTAssertEqual(Pragma.JournalMode.persist.sqlValue,  "PERSIST")
        XCTAssertEqual(Pragma.JournalMode.memory.sqlValue,   "MEMORY")
        XCTAssertEqual(Pragma.JournalMode.wal.sqlValue,      "WAL")
    }
}
