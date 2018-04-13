//
//  SQLite.BlobTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-03.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class SQLite_BlobTests: XCTestCase {
    
    private let seedData = Data(bytes: [
        0xAB, 0x00, 0x00, 0x00, 0x00, 0x00, 0xAB, 0x00,
        0x00, 0xCD, 0x00, 0x00, 0x00, 0xEF, 0x00, 0xCD,
        0x00, 0x00, 0xEF, 0x00, 0xCD, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0xAB, 0x00, 0x00, 0x00, 0x00,
    ])
    
    private let replacementData = Data(bytes: [
        0xCC, 0xDD, 0xEE, 0xBB, 0xCC, 0xDD, 0xEE, 0xBB,
        0xCC, 0xDD, 0xEE, 0xBB, 0xCC, 0xDD, 0xEE, 0xBB,
        0xCC, 0xDD, 0xEE, 0xBB, 0xCC, 0xDD, 0xEE, 0xBB,
        0xCC, 0xDD, 0xEE, 0xBB, 0xCC, 0xDD, 0xEE, 0xBB,
    ])
    
    private let partialData = Data(bytes: [
        0xCD, 0xCD, 0xCD, 0xCD, 0xCD, 0xCD, 0xCD, 0xCD,
    ])
    
    // ----------------------------------
    //  MARK: - Init -
    //
    func testInitSuccess() {
        let sqlite = self.seededDatabase()
        
        XCTAssertWontThrow {
            let blob = try sqlite.open(table: "animal", column: "image", rowID: 900, mode: .readWrite)
            XCTAssertNotNil(blob)
            XCTAssertEqual(blob.count, 32)
        }
    }
    
    func testInitFailure() {
        let sqlite = self.seededDatabase()
        
        XCTAssertWillThrow(Status.error) {
            let _ = try sqlite.open(table: "person", column: "photo", rowID: 13, mode: .readWrite)
        }
    }
    
    // ----------------------------------
    //  MARK: - I/O -
    //
    func testRead() {
        let blob = self.openBlob()
        
        XCTAssertWontThrow {
            let data = try blob.read(count: 32)
            XCTAssertEqual(data, self.seedData)
        }
    }
    
    func testReadPartial() {
        let blob = self.openBlob()
        
        XCTAssertWontThrow {
            let data = try blob.read(count: 3, at: 18)
            XCTAssertEqual(data, Data(bytes: [
                0xEF, 0x00, 0xCD,
            ]))
        }
    }
    
    func testReadInvalid() {
        let blob = self.openBlob()
        
        XCTAssertWillThrow(Status.error) {
            _ = try blob.read(count: 999)
        }
    }
    
    func testWrite() {
        let blob = self.openBlob()
        
        XCTAssertWontThrow {
            try blob.write(self.replacementData)
        }
        
        let data = try! blob.read(count: 32)
        XCTAssertEqual(data, self.replacementData)
    }
    
    func testWritePartial() {
        let blob = self.openBlob()
        
        XCTAssertWontThrow {
            try blob.write(self.partialData, at: 16)
        }
        
        let data = try! blob.read(count: self.partialData.count, at: 16)
        XCTAssertEqual(data, self.partialData)
    }
    
    func testWriteInvalid() {
        let blob = self.openBlob()
        
        XCTAssertWillThrow(Status.error) {
            let data = Data(count: 999)
            _ = try blob.write(data)
        }
    }
    
    func testReopen() {
        let blob = self.openBlob()
        
        XCTAssertWontThrow {
            for i in 900...902 {
                try blob.reopen(rowID: i)
                let data = try blob.read(count: self.seedData.count)
                XCTAssertEqual(data, self.seedData)
            }
        
            for i in 900...902 {
                try blob.reopen(rowID: i)
                try blob.write(self.replacementData)
            }
            
            for i in 900...902 {
                try blob.reopen(rowID: i)
                let data = try blob.read(count: self.replacementData.count)
                XCTAssertEqual(data, self.replacementData)
            }
        }
    }
    
    func testReopenInvalid() {
        let blob = self.openBlob()
        
        XCTAssertWillThrow(Status.error) {
            _ = try blob.reopen(rowID: 99999)
        }
    }

    // ----------------------------------
    //  MARK: - Mode -
    //
    func testModeInit() {
        XCTAssertEqual(SQLite.Blob.Mode(rawValue: 0),   .readOnly)
        XCTAssertEqual(SQLite.Blob.Mode(rawValue: 1),   .readWrite)
        XCTAssertEqual(SQLite.Blob.Mode(rawValue: -1),  .readWrite)
        XCTAssertEqual(SQLite.Blob.Mode(rawValue: 99),  .readWrite)
        XCTAssertEqual(SQLite.Blob.Mode(rawValue: -99), .readWrite)
    }
    
    func testRawValue() {
        XCTAssertEqual(SQLite.Blob.Mode.readOnly.rawValue,  0)
        XCTAssertEqual(SQLite.Blob.Mode.readWrite.rawValue, 1)
    }
    
    // ----------------------------------
    //  MARK: - Utilities -
    //
    private func openBlob() -> SQLite.Blob {
        let sqlite = self.seededDatabase()
        return try! sqlite.open(table: "animal", column: "image", rowID: 900, mode: .readWrite)
    }
    
    private func seededDatabase() -> SQLite {
        let sqlite = SQLite.default()
        
        try! sqlite.performTransaction {
            for i in 0..<3 {
                try sqlite.execute(query: "INSERT INTO animal (id, image) VALUES (?, ?)", arguments: 900 + i, self.seedData)
            }
            return .commit
        }
        
        return sqlite
    }
}
