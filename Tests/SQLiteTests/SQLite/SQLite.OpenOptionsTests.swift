//
//  SQLite.OpenOptionsTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-20.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
import sqlite3
import SQLite

class SQLite_OpenOptionsTests: XCTestCase {
    
    func testValues() {
        XCTAssertEqual(SQLite.OpenOptions.readOnly.rawValue,     SQLITE_OPEN_READONLY)
        XCTAssertEqual(SQLite.OpenOptions.readWrite.rawValue,    SQLITE_OPEN_READWRITE)
        XCTAssertEqual(SQLite.OpenOptions.create.rawValue,       SQLITE_OPEN_CREATE)
        XCTAssertEqual(SQLite.OpenOptions.uri.rawValue,          SQLITE_OPEN_URI)
        XCTAssertEqual(SQLite.OpenOptions.memory.rawValue,       SQLITE_OPEN_MEMORY)
        XCTAssertEqual(SQLite.OpenOptions.noMutex.rawValue,      SQLITE_OPEN_NOMUTEX)
        XCTAssertEqual(SQLite.OpenOptions.fullMutex.rawValue,    SQLITE_OPEN_FULLMUTEX)
        XCTAssertEqual(SQLite.OpenOptions.sharedCache.rawValue,  SQLITE_OPEN_SHAREDCACHE)
        XCTAssertEqual(SQLite.OpenOptions.privateCache.rawValue, SQLITE_OPEN_PRIVATECACHE)
    }
    
    func testCombinedValues() {
        var options: SQLite.OpenOptions = []
            
        options = [.readWrite, .create]
        XCTAssertEqual(options.rawValue, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE)
        
        options = [.memory, .noMutex]
        XCTAssertEqual(options.rawValue, SQLITE_OPEN_MEMORY | SQLITE_OPEN_NOMUTEX)
    }
}
