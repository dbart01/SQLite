//
//  ColumnMetadataTests.swift
//  SQLite
//
//  Created by Dima Bart on 2017-06-06.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
import SQLite

class ColumnMetadataTests: XCTestCase {

    // MARK: - ValueType -

    func testValidValueType() {
        XCTAssertEqual(ValueType(type: "INTEGER"), .integer)
        XCTAssertEqual(ValueType(type: "REAL"),    .double)
        XCTAssertEqual(ValueType(type: "TEXT"),    .text)
        XCTAssertEqual(ValueType(type: "BLOB"),    .blob)
    }
    
    func testInvalidValueType() {
        XCTAssertEqual(ValueType(type: "SOMETHING"), nil)
    }
    
    func testValueTypeEquality() {
        let int1   = ValueType.integer
        let int2   = ValueType.integer
        let double = ValueType.double
        
        XCTAssertEqual(int1, int2)
        XCTAssertNotEqual(int1, double)
    }
    
    // MARK: - CollationSequence -

    func testCollationSequence() {
        XCTAssertEqual(CollationSequence(sequence: "BINARY"), .binary)
        XCTAssertEqual(CollationSequence(sequence: "NOCASE"), .nocase)
        XCTAssertEqual(CollationSequence(sequence: "RTRIM"),  .rtrim)
        XCTAssertEqual(CollationSequence(sequence: "CUSTOM"), .custom("CUSTOM"))
    }
    
    func testCollationSequenceEquality() {
        let binary1 = CollationSequence.binary
        let binary2 = CollationSequence.binary
        let nocase  = CollationSequence.nocase
        let custom  = CollationSequence.custom("CUSTOM")
        
        XCTAssertEqual(binary1, binary2)
        XCTAssertNotEqual(binary1, nocase)
        XCTAssertNotEqual(binary1, custom)
    }
    
    // MARK: - Metadata -

    func testMetadataInit() {
        let metadata = ColumnMetadata(
            type:            "INTEGER",
            collation:       "BINARY",
            isNotNull:       true,
            isPrimaryKey:    true,
            isAutoIncrement: true
        )
        
        XCTAssertEqual(metadata.type,            .integer)
        XCTAssertEqual(metadata.collation,       .binary)
        XCTAssertEqual(metadata.isNotNull,       true)
        XCTAssertEqual(metadata.isPrimaryKey,    true)
        XCTAssertEqual(metadata.isAutoIncrement, true)
    }
    
    func testMetadataEquality() {
        let metadata1 = ColumnMetadata(
            type:            "TEXT",
            collation:       "NOCASE",
            isNotNull:       false,
            isPrimaryKey:    false,
            isAutoIncrement: true
        )
        
        let metadata2 = ColumnMetadata(
            type:            "TEXT",
            collation:       "NOCASE",
            isNotNull:       false,
            isPrimaryKey:    false,
            isAutoIncrement: true
        )
        
        let metadata3 = ColumnMetadata(
            type:            "BLOB",
            collation:       "BINARY",
            isNotNull:       false,
            isPrimaryKey:    false,
            isAutoIncrement: true
        )
        
        XCTAssertEqual(metadata1, metadata2)
        XCTAssertNotEqual(metadata2, metadata3)
    }
}
