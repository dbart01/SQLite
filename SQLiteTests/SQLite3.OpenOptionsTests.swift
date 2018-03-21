//
//  SQLite3.OpenOptionsTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-20.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
import SQLite

class SQLite3_OpenOptionsTests: XCTestCase {
    
    func testValues() {
        XCTAssertEqual(SQLite3.OpenOptions.readOnly.rawValue,     SQLITE_OPEN_READONLY)
        XCTAssertEqual(SQLite3.OpenOptions.readWrite.rawValue,    SQLITE_OPEN_READWRITE)
        XCTAssertEqual(SQLite3.OpenOptions.create.rawValue,       SQLITE_OPEN_CREATE)
        XCTAssertEqual(SQLite3.OpenOptions.uri.rawValue,          SQLITE_OPEN_URI)
        XCTAssertEqual(SQLite3.OpenOptions.memory.rawValue,       SQLITE_OPEN_MEMORY)
        XCTAssertEqual(SQLite3.OpenOptions.noMutex.rawValue,      SQLITE_OPEN_NOMUTEX)
        XCTAssertEqual(SQLite3.OpenOptions.fullMutex.rawValue,    SQLITE_OPEN_FULLMUTEX)
        XCTAssertEqual(SQLite3.OpenOptions.sharedCache.rawValue,  SQLITE_OPEN_SHAREDCACHE)
        XCTAssertEqual(SQLite3.OpenOptions.privateCache.rawValue, SQLITE_OPEN_PRIVATECACHE)
    }
    
    func testCombinedValues() {
        var options: SQLite3.OpenOptions = []
            
        options = [.readWrite, .create]
        XCTAssertEqual(options.rawValue, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE)
        
        options = [.memory, .noMutex]
        XCTAssertEqual(options.rawValue, SQLITE_OPEN_MEMORY | SQLITE_OPEN_NOMUTEX)
    }
}
