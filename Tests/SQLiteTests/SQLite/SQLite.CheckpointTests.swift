//
//  SQLite.CheckpointTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-02.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
import sqlite3
@testable import SQLite

class SQLite_CheckpointTests: XCTestCase {

    // MARK: - Values -

    func testInit() {
        XCTAssertEqual(SQLite.Checkpoint(rawValue: SQLITE_CHECKPOINT_PASSIVE),  .passive)
        XCTAssertEqual(SQLite.Checkpoint(rawValue: SQLITE_CHECKPOINT_FULL),     .full)
        XCTAssertEqual(SQLite.Checkpoint(rawValue: SQLITE_CHECKPOINT_RESTART),  .restart)
        XCTAssertEqual(SQLite.Checkpoint(rawValue: SQLITE_CHECKPOINT_TRUNCATE), .truncate)
        XCTAssertEqual(SQLite.Checkpoint(rawValue: 812394789),                  nil)
    }
    
    func testRawValue() {
        XCTAssertEqual(SQLite.Checkpoint.passive.rawValue,  SQLITE_CHECKPOINT_PASSIVE)
        XCTAssertEqual(SQLite.Checkpoint.full.rawValue,     SQLITE_CHECKPOINT_FULL)
        XCTAssertEqual(SQLite.Checkpoint.restart.rawValue,  SQLITE_CHECKPOINT_RESTART)
        XCTAssertEqual(SQLite.Checkpoint.truncate.rawValue, SQLITE_CHECKPOINT_TRUNCATE)
    }
    
    // MARK: - Checkpoint -

    func testCheckpoint() {
        let sqlite     = SQLite.local()
        let walEnabled = try! sqlite.set(pragma: Pragma.journalMode, value: .wal)
        XCTAssertTrue(walEnabled)
        
        /* -----------------------------------
         ** Write the first batch of 900 items
         ** and ensure that we have 8 pages in
         ** the WAL journal.
         */
        sqlite.hook.wal = .init { database, pageCount in
            XCTAssertEqual(pageCount, 8)
            return .ok
        }

        try! sqlite.performTransaction {
            for i in 0..<900 {
                try sqlite.execute(query: "INSERT INTO animal (id, name, type) VALUES (?, 'camel', 'mamal')", arguments: 1000 + i)
            }
            return .commit
        }
        
        /* ---------------------------------
         ** Execute the checkpoint and repeat
         ** a batch write to verify that only
         ** 8 pages are in the WAL journal.
         */
        sqlite.checkpoint()
        
        sqlite.hook.wal = .init { database, pageCount in
            XCTAssertEqual(pageCount, 9)
            return .ok
        }
        
        try! sqlite.performTransaction {
            for i in 0..<900 {
                try sqlite.execute(query: "INSERT INTO animal (id, name, type) VALUES (?, 'camel', 'mamal')", arguments: 2000 + i)
            }
            return .commit
        }
    }
}
