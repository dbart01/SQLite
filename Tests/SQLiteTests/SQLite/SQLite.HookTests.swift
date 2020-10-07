//
//  SQLite.HookTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-29.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class SQLite_HookTests: XCTestCase {

    // MARK: - Init -

    func testInit() {
        let sqlite = SQLite.default()
        
        XCTAssertNil(sqlite.hook.update)
        XCTAssertNil(sqlite.hook.commit)
        XCTAssertNil(sqlite.hook.rollback)
        XCTAssertNil(sqlite.hook.preupdate)
        XCTAssertNil(sqlite.hook.wal)
    }
    
    // MARK: - Hooks -

    func testUpdateHook() {
        let sqlite = SQLite.default()
        let e = self.expectation(description: "Should call update hook")
        
        sqlite.hook.update = .init { action, database, table, rowID in
            e.fulfill()
            XCTAssertEqual(action,   .update)
            XCTAssertEqual(database, "main")
            XCTAssertEqual(table,    "animal")
            XCTAssertEqual(rowID,    6)
        }
        
        try! sqlite.execute(query: "UPDATE animal SET name = 'Mountain Lion' WHERE id = 6")
        
        sqlite.hook.update = nil
        
        self.wait(for: [e], timeout: 1.0)
    }
    
    func testCommitHookSuccess() {
        let sqlite = SQLite.default()
        let e = self.expectation(description: "Should call commit hook")
        
        sqlite.hook.commit = .init {
            e.fulfill()
            return true
        }
        
        try! sqlite.execute(query: "INSERT INTO animal (id, name, type) VALUES (888, 'sheep', 'mamal')")
        
        sqlite.hook.commit = nil
        
        try! sqlite.execute(query: "SELECT id FROM animal WHERE id = 888", dictionaryHandler: { result, dictionary in
            XCTAssertEqual(result, .row)
            XCTAssertEqual(dictionary["id"] as! Int, 888)
        })
        
        self.wait(for: [e], timeout: 1.0)
    }
    
    func testCommitHookFailure() {
        let sqlite = SQLite.default()
        let e = self.expectation(description: "Should call commit hook")
        
        sqlite.hook.commit = .init {
            e.fulfill()
            return false
        }
        
        XCTAssertWillThrow(Status.constraint) {
            try sqlite.execute(query: "INSERT INTO animal (id, name, type) VALUES (888, 'sheep', 'mamal')")
        }
        
        sqlite.hook.commit = nil
        
        try! sqlite.execute(query: "SELECT id FROM animal WHERE id = 888", dictionaryHandler: { result, dictionary in
            XCTAssertEqual(result, .row)
            XCTAssertNil(dictionary)
        })
        
        self.wait(for: [e], timeout: 1.0)
    }
    
    func testRollback() {
        let sqlite = SQLite.default()
        let e = self.expectation(description: "Should call rollback hook")
        
        sqlite.hook.rollback = .init {
            e.fulfill()
        }
        
        try! sqlite.performTransaction {
            try! sqlite.execute(query: "INSERT INTO animal (id, name, type) VALUES (888, 'sheep', 'mamal')")
            return .rollback
        }
        
        sqlite.hook.rollback = nil
        
        try! sqlite.execute(query: "SELECT id FROM animal WHERE id = 888", dictionaryHandler: { result, dictionary in
            XCTAssertEqual(result, .row)
            XCTAssertNil(dictionary)
        })
        
        self.wait(for: [e], timeout: 1.0)
    }
    
    func testPreupdate() {
        let sqlite = SQLite.default()
        let e = self.expectation(description: "Should call preupdate hook")
        
        sqlite.hook.preupdate = .init { action, database, table, oldID, newID in
            e.fulfill()
            XCTAssertEqual(action,   .update)
            XCTAssertEqual(database, "main")
            XCTAssertEqual(table,    "animal")
            XCTAssertEqual(oldID,    999)
            XCTAssertEqual(newID,    876)
        }
        
        try! sqlite.execute(query: "UPDATE animal SET id = 876, name = 'sheep', type = 'mamal' WHERE id = 999")
        
        sqlite.hook.preupdate = nil
        
        self.wait(for: [e], timeout: 1.0)
    }
    
    func testWalSucess() {
        let sqlite     = SQLite.local()
        let walEnabled = try! sqlite.set(pragma: Pragma.journalMode, value: .wal)
        XCTAssertTrue(walEnabled)
        
        let e = self.expectation(description: "Should call wal hook")
        
        sqlite.hook.wal = .init { database, pageCount in
            e.fulfill()
            XCTAssertEqual(database, "main")
            XCTAssertEqual(pageCount, 1)
            return .ok
        }
        
        try! sqlite.execute(query: "INSERT INTO animal (id, name, type) VALUES (800, 'goat', 'mamal')")

        sqlite.hook.wal = nil
        
        self.wait(for: [e], timeout: 1.0)
    }
    
    func testWalFailure() {
        let sqlite     = SQLite.local()
        let walEnabled = try! sqlite.set(pragma: Pragma.journalMode, value: .wal)
        XCTAssertTrue(walEnabled)
        
        let e = self.expectation(description: "Should call wal hook")
        
        sqlite.hook.wal = .init { database, pageCount in
            e.fulfill()
            XCTAssertEqual(database, "main")
            XCTAssertEqual(pageCount, 1)
            return .abort
        }
        
        XCTAssertWillThrow(Status.error) {
            try sqlite.execute(query: "INSERT INTO animal (id, name, type) VALUES (800, 'goat', 'mamal')")
        }
        
        sqlite.hook.wal = nil
        
        self.wait(for: [e], timeout: 1.0)
    }
}
