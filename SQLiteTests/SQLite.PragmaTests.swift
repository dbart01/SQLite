//
//  SQLite.PragmaTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
import SQLite

class SQLite_PragmaTests: XCTestCase {
    
    func testPragmaForeignKeys() {
        let sqlite = SQLite.local()
        
        XCTAssertWontThrow {
            let currentValue = try sqlite.get(pragma: Pragma.foreignKeys)
            XCTAssertEqual(currentValue, .off)
            
            let result = try sqlite.set(pragma: Pragma.foreignKeys, value: .on)
            XCTAssertEqual(result, true)
            
            let updatedValue = try sqlite.get(pragma: Pragma.foreignKeys)
            XCTAssertEqual(updatedValue, .on)
        }
    }
    
    func testPragmaApplicationID() {
        let sqlite = SQLite.local()
        
        XCTAssertWontThrow {
            let currentValue = try sqlite.get(pragma: Pragma.applicationID)
            XCTAssertEqual(currentValue, 0)
            
            let result = try sqlite.set(pragma: Pragma.applicationID, value: 13)
            XCTAssertEqual(result, true)
            
            let updatedValue = try sqlite.get(pragma: Pragma.applicationID)
            XCTAssertEqual(updatedValue, 13)
        }
    }
    
    func testPragmaEncoding() {
        let sqlite = SQLite.local()
        
        XCTAssertWontThrow {
            let currentValue = try sqlite.get(pragma: Pragma.encoding)
            XCTAssertEqual(currentValue, .utf8)
            
            let result = try sqlite.set(pragma: Pragma.encoding, value: .utf16)
            XCTAssertEqual(result, true)
            
            let updatedValue = try sqlite.get(pragma: Pragma.encoding)
            XCTAssertEqual(updatedValue, .utf8) // Can't change encoding after database is created
        }
    }
    
    func testPragmaCacheSize() {
        let sqlite = SQLite.local()
        
        XCTAssertWontThrow {
            let currentValue = try sqlite.get(pragma: Pragma.cacheSize)
            XCTAssertEqual(currentValue, .kilobytes(2000))
            
            let result = try sqlite.set(pragma: Pragma.cacheSize, value: .pages(32))
            XCTAssertEqual(result, true)
            
            let updatedValue = try sqlite.get(pragma: Pragma.cacheSize)
            XCTAssertEqual(updatedValue, .pages(32))
        }
    }
    
    func testPragmaJournalMode() {
        let sqlite = SQLite.local()
        
        XCTAssertWontThrow {
            let currentValue = try sqlite.get(pragma: Pragma.journalMode)
            XCTAssertEqual(currentValue, .memory)
            
            let result = try sqlite.set(pragma: Pragma.journalMode, value: .off)
            XCTAssertEqual(result, true)
            
            let updatedValue = try sqlite.get(pragma: Pragma.journalMode)
            XCTAssertEqual(updatedValue, .off)
        }
    }
}
