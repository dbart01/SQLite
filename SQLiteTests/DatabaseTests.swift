//
//  DatabaseTests.swift
//  SQLite
//
//  Created by Dima Bart on 2017-05-21.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
import SQLite

class DatabaseTests: XCTestCase {
 
    private static let tempURL     = URL(fileURLWithPath: NSTemporaryDirectory())
    private static let databaseURL = DatabaseTests.tempURL.appendingPathComponent("test.sqlite")
    
    private let fileManager = FileManager.default
    
    // ----------------------------------
    //  MARK: - Setup -
    //
    override func setUp() {
        super.setUp()
        
        try? self.fileManager.removeItem(at: DatabaseTests.databaseURL)
    }
    
    // ----------------------------------
    //  MARK: - Open -
    //
    func testOpenValidConnection() {
        let exists = self.fileManager.fileExists(atPath: DatabaseTests.databaseURL.path)
        XCTAssertFalse(exists)
        
        do {
            let sqlite = try SQLite3(at: DatabaseTests.databaseURL)
            
            XCTAssertNotNil(sqlite)
            let sqliteExists = self.fileManager.fileExists(atPath: DatabaseTests.databaseURL.path)
            XCTAssertTrue(sqliteExists)
            
        } catch {
            XCTFail()
        }
    }
    
    func testOpenInvalidConnection() {
        do {
            let _ = try SQLite3(at: URL(fileURLWithPath: "/invalid.sqlite"))
            XCTFail()
        } catch Status.cantOpen {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }
    
    func testPrepareValidStatement() {
        let sqlite = self.openSQLite()
        let query  = "CREATE TABLE animal (id INTEGER primary key autoincrement, name TEXT, type TEXT);"
        
        do {
            let statement = try sqlite.prepare(query: query)
            XCTAssertNotNil(statement)
            XCTAssertEqual(statement.query, query)
        } catch {
            XCTFail()
        }
    }
    
    func testPrepareInvalidStatement() {
        let sqlite = self.openSQLite()
        let query  = "SELECT * FROM vehicle"
        
        do {
            let _ = try sqlite.prepare(query: query)
            XCTFail()
        } catch Status.error {
            XCTAssertTrue(true)
        } catch {
            XCTFail()
        }
    }
    
    // ----------------------------------
    //  MARK: - Private -
    //
    private func openSQLite() -> SQLite3 {
        return try! SQLite3(at: DatabaseTests.databaseURL)
    }
}
