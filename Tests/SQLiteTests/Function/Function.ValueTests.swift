//
//  Function.ValueTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-10.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
import sqlite3
@testable import SQLite

class Function_ValueTests: XCTestCase {

    private lazy var sqlite:   SQLite   = SQLite.default()
    private lazy var function: Function = {
        let description = Function.Description(
            name:          "xct_double",
            arguments:     .finite(1),
            encoding:      .utf8,
            deterministic: true
        )
        
        return try! DoubleFunction(sqlite: self.sqlite, description: description)
    }()
    
    // MARK: - Setup -

    override func setUp() {
        super.setUp()
        
        _ = self.function
    }
    
    // MARK: - Init -

    func testCollectionInit() {
        let values = Function.Value.collection(argc: 1, argv: self.valueForID())
        XCTAssertEqual(values.count, 1)
    }
    
    // MARK: - Generic Values -

    func testGenericBool() {
        let id = self.functionValueForID()
        
        XCTAssertEqual(try! id.typed(), true)
    }
    
    func testGenericInteger() {
        let id = self.functionValueForID()
        
        XCTAssertEqual(try! id.typed(), 10 as Int)
        XCTAssertEqual(try! id.typed(), 10 as Int8)
        XCTAssertEqual(try! id.typed(), 10 as Int16)
        XCTAssertEqual(try! id.typed(), 10 as Int32)
        XCTAssertEqual(try! id.typed(), 10 as Int64)
        XCTAssertEqual(try! id.typed(), 10 as UInt)
        XCTAssertEqual(try! id.typed(), 10 as UInt8)
        XCTAssertEqual(try! id.typed(), 10 as UInt16)
        XCTAssertEqual(try! id.typed(), 10 as UInt32)
        XCTAssertEqual(try! id.typed(), 10 as UInt64)
    }
    
    func testGenericString() {
        let integer = self.functionValueForID()
        let image   = self.functionValueForImage()
        
        XCTAssertEqual(try! integer.typed(), "10")
        XCTAssertEqual(try! image.typed(), Optional<String>.none)
    }
    
    func testGenericURL() {
        let name  = self.functionValueForName()
        let image = self.functionValueForImage()
        
        XCTAssertEqual(try! name.typed(), URL(string: "crocodile"))
        XCTAssertEqual(try! image.typed(), Optional<URL>.none)
    }
    
    func testGenericFloat() {
        let length = self.functionValueForLength()
        
        XCTAssertEqual(try! length.typed(), 2987.83 as Decimal)
        XCTAssertEqual(try! length.typed(), 2987.83 as Float)
        XCTAssertEqual(try! length.typed(), 2987.83 as Double)
    }
    
    func testGenericData() {
        let id    = self.functionValueForID()
        let image = self.functionValueForImage()
        
        XCTAssertEqual(try! id.typed(), Data([0x31, 0x30]))
        XCTAssertEqual(try! image.typed(), Optional<Data>.none)
    }
    
    func testGenericInvalidType() {
        let id = self.functionValueForID()
        
        XCTAssertWillThrow(Function.Value.Error.invalidType) {
            var _: Dictionary<String, String>? = try id.typed()
        }
    }
    
    // MARK: - Values -

    func testIntegerValue() {
        let value = self.functionValueForID()
        
        XCTAssertEqual(value.integer, 10)
    }
    
    func testDoubleValue() {
        let value = self.functionValueForID()
        
        XCTAssertEqual(value.double, 10.0)
    }
    
    func testStringValue() {
        let value = self.functionValueForID()
        
        XCTAssertEqual(value.string, "10")
    }
    
    func testStringValueNull() {
        let value = Function.Value.collection(argc: 1, argv: self.valueForImage()).first!
        
        XCTAssertEqual(value.string, nil)
    }
    
    func testBlobValue() {
        let value = self.functionValueForID()
        
        XCTAssertEqual(value.blob, Data([0x31, 0x30]))
    }
    
    func testBlobValueNull() {
        let value = self.functionValueForImage()
        XCTAssertEqual(value.blob, nil)
    }
    
    // MARK: - Utilities -

    private func functionValueForID() -> Function.Value {
        return Function.Value.collection(argc: 1, argv: self.valueForID()).first!
    }
    
    private func functionValueForName() -> Function.Value {
        return Function.Value.collection(argc: 1, argv: self.valueForName()).first!
    }
    
    private func functionValueForLength() -> Function.Value {
        return Function.Value.collection(argc: 1, argv: self.valueForLength()).first!
    }
    
    private func functionValueForImage() -> Function.Value {
        return Function.Value.collection(argc: 1, argv: self.valueForImage()).first!
    }
    
    private func valueForID() -> UnsafeMutablePointer<_Value?> {
        return self.value(at: 0)
    }
    
    private func valueForName() -> UnsafeMutablePointer<_Value?> {
        return self.value(at: 1)
    }

    private func valueForLength() -> UnsafeMutablePointer<_Value?> {
        return self.value(at: 2)
    }
    
    private func valueForImage() -> UnsafeMutablePointer<_Value?> {
        return self.value(at: 3)
    }
    
    private func value(at column: Int) -> UnsafeMutablePointer<_Value?> {
        var value: _Value?
        try! self.sqlite.execute(query: "SELECT id, name, length, image FROM animal WHERE id = 10") { result, statement in
            value = sqlite3_value_dup(sqlite3_column_value(statement.statement, Int32(column)))
        }
        
        let pointer = UnsafeMutablePointer<_Value?>.allocate(capacity: 1)
        pointer.initialize(to: value!)
        return pointer
    }
}
