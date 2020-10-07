//
//  SQLite.BackupTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-03.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class SQLite_BackupTests: XCTestCase {

    // MARK: - Init -

    func testInit() {
        let source      = SQLite.default()
        let destination = SQLite.emptyInMemory()
        
        XCTAssertWontThrow {
            let backup = try SQLite.Backup(
                from: source,
                sourceName: "main",
                to: destination,
                destinationName: "main"
            )
            
            XCTAssertNotNil(backup)
        }
    }
    
    func testInitFailure() {
        let source      = SQLite.default()
        let destination = SQLite.emptyInMemory()
        
        try! destination.performTransaction(.immediate) {
            
            XCTAssertWillThrow(Status.error) {
                let _ = try SQLite.Backup(
                    from: source,
                    sourceName: "main",
                    to: destination,
                    destinationName: "main"
                )
            }
            
            return .rollback
        }
    }
    
    // MARK: - Copy -

    func testCopy() {
        let source      = SQLite.default()
        let destination = SQLite.emptyInMemory()
        
        XCTAssertWontThrow {
            let backup = try SQLite.Backup(from: source, to: destination)
            var status = Status.ok
            
            let buffer = 1
            let count  = 3
            var copied = 0
            
            repeat {
                status = try backup.copy(pages: buffer) { total, remaining in
                    copied += buffer
                    XCTAssertEqual(total, count)
                    XCTAssertEqual(remaining, count - copied)
                }
            } while status == .ok
        }
        
        let compareQuery = "SELECT * FROM animal ORDER BY id"
        
        var sourceResults:      Int = 0
        var destinationResults: Int = 0
        
        try! source.execute(query: compareQuery) { (result, dictionary: [String : Any]) in
            sourceResults += 1
        }
        
        try! destination.execute(query: compareQuery) { (result, dictionary: [String : Any]) in
            destinationResults += 1
        }
        
        XCTAssertEqual(sourceResults, destinationResults)
    }
    
    func testCopyFailure() {
        let source      = SQLite.default()
        let destination = SQLite.emptyInMemory(options: [.readOnly])

        let backup = try! SQLite.Backup(from: source, to: destination)
        
        XCTAssertWillThrow(Status.readOnly) {
            _ = try backup.copy(pages: 1)
        }
    }
}
