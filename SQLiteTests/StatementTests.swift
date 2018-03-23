//
//  StatementTests.swift
//  SQLite
//
//  Created by Dima Bart on 2017-06-05.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class StatementTests: XCTestCase {
    
    // ----------------------------------
    //  MARK: - Reference -
    //
    func testSqliteReference() {
        let sqlite    = SQLite3.local()
        let statement = try! sqlite.prepare(query: "SELECT * FROM animal")
        
        XCTAssertTrue(statement.sqlite === sqlite)
    }
    
    // ----------------------------------
    //  MARK: - State -
    //
    func testIsBusy() {
        let statement = SQLite3.prepared(query: "SELECT * FROM animal")
        
        XCTAssertFalse(statement.isBusy)
        
        try! statement.step()
        
        XCTAssertTrue(statement.isBusy)
    }
    
    func testIsReadOnly() {
        let statement1 = SQLite3.prepared(query: "SELECT * FROM animal")
        XCTAssertTrue(statement1.isReadOnly)
        
        let statement2 = SQLite3.prepared(query: "UPDATE animal SET name = 'dog' WHERE id = 3")
        XCTAssertFalse(statement2.isReadOnly)
    }

    // ----------------------------------
    //  MARK: - Parameters -
    //
    func testParameters() {
        let query     = "SELECT * FROM animal WHERE name = :name AND type = :type"
        let statement = SQLite3.prepared(query: query)
        
        XCTAssertEqual(statement.parameterCount, 2)
        XCTAssertEqual(statement.parameterName(for: 0), ":name")
        XCTAssertEqual(statement.parameterName(for: 1), ":type")
        
        XCTAssertEqual(statement.parameterIndex(for: ":name"), 0)
        XCTAssertEqual(statement.parameterIndex(for: ":type"), 1)
    }
    
    func testInvalidParameters() {
        let query     = "SELECT * FROM animal"
        let statement = SQLite3.prepared(query: query)
        
        XCTAssertEqual(statement.parameterCount, 0)
        XCTAssertEqual(statement.parameterName(for: 0), nil)
        XCTAssertEqual(statement.parameterName(for: 1), nil)
        
        XCTAssertEqual(statement.parameterIndex(for: ":name"), nil)
        XCTAssertEqual(statement.parameterIndex(for: ":type"), nil)
    }
    
    func testBindNilParameters() {
        let query     = "SELECT * FROM animal WHERE id = ? OR name = ? OR length = ? OR image = ?"
        let expanded  = "SELECT * FROM animal WHERE id = NULL OR name = NULL OR length = NULL OR image = NULL"
        let statement = SQLite3.prepared(query: query)
        
        XCTAssertWontThrow {
            try statement.bind(integer: nil, to: 0)
            try statement.bind(string:  nil, to: 1)
            try statement.bind(double:  nil, to: 2)
            try statement.bind(blob:    nil, to: 3)
            
            XCTAssertEqual(statement.expandedQuery, expanded)
            XCTAssertEqual(statement.query, query)
        }
    }
    
    func testBindValidParameters() {
        let query     = "SELECT * FROM animal WHERE id = ? OR name = ? OR length = ? OR image = ?"
        let statement = SQLite3.prepared(query: query)
        
        XCTAssertWontThrow {
            try statement.bind(integer: 13,        to: 0)
            try statement.bind(string:  "reptile", to: 1)
            try statement.bind(double:  261.56,    to: 2)
            try statement.bind(blob:    Data(),    to: 3)
            
            let expanded = "SELECT * FROM animal WHERE id = 13 OR name = 'reptile' OR length = 261.56 OR image = x''"
            XCTAssertEqual(statement.expandedQuery, expanded)
            
            try statement.clearBindings()
            
            let cleared = "SELECT * FROM animal WHERE id = NULL OR name = NULL OR length = NULL OR image = NULL"
            XCTAssertEqual(statement.expandedQuery, cleared)
            XCTAssertEqual(statement.query, query)
        }
    }
    
    func testBindGenericParameters() {
        XCTAssertWontThrow {
            let query     = "SELECT * FROM animal WHERE id = ?"
            let expanded  = "SELECT * FROM animal WHERE id = 1"
            let statement = SQLite3.prepared(query: query)
            
            try statement.bind(true, to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
        }
        
        XCTAssertWontThrow {
            let query     = "SELECT * FROM animal WHERE id = ?"
            let expanded  = "SELECT * FROM animal WHERE id = 0"
            let statement = SQLite3.prepared(query: query)
            
            try statement.bind(false, to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
        }
        
        XCTAssertWontThrow {
            let query     = "SELECT * FROM animal WHERE id = ?"
            let expanded  = "SELECT * FROM animal WHERE id = NULL"
            let statement = SQLite3.prepared(query: query)
            
            let value: Int? = nil
            
            try statement.bind(value, to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
        }
        
        XCTAssertWontThrow {
            let query     = "SELECT * FROM animal WHERE id = ?"
            let expanded  = "SELECT * FROM animal WHERE id = 13"
            let statement = SQLite3.prepared(query: query)
            
            try statement.bind(13 as Int, to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
            
            try statement.bind(13 as Int8, to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
            
            try statement.bind(13 as Int16, to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
            
            try statement.bind(13 as Int32, to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
            
            try statement.bind(13 as Int64, to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
        }
        
        XCTAssertWontThrow {
            let query     = "SELECT * FROM animal WHERE id = ?"
            let expanded  = "SELECT * FROM animal WHERE id = 13"
            let statement = SQLite3.prepared(query: query)
            
            try statement.bind(13 as UInt, to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
            
            try statement.bind(13 as UInt8, to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
            
            try statement.bind(13 as UInt16, to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
            
            try statement.bind(13 as UInt32, to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
            
            try statement.bind(13 as UInt64, to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
        }
        
        XCTAssertWontThrow {
            let query     = "SELECT * FROM animal WHERE name = ?"
            let expanded  = "SELECT * FROM animal WHERE name = 'bulldog'"
            let statement = SQLite3.prepared(query: query)
            
            try statement.bind("bulldog", to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
        }
        
        XCTAssertWontThrow {
            let query     = "SELECT * FROM animal WHERE length = ?"
            let expanded  = "SELECT * FROM animal WHERE length = 261.5"
            let statement = SQLite3.prepared(query: query)
            
            try statement.bind(261.5 as Float, to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
            
            try statement.bind(261.5 as Double, to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
        }
        
        XCTAssertWontThrow {
            let query     = "SELECT * FROM animal WHERE image = ?"
            let expanded  = "SELECT * FROM animal WHERE image = x''"
            let statement = SQLite3.prepared(query: query)
            
            try statement.bind(Data(), to: 0)
            XCTAssertEqual(statement.expandedQuery, expanded)
            try statement.clearBindings()
        }
    }
    
    func testBindInvalidParameters() {
        let query     = "SELECT * FROM animal"
        let statement = SQLite3.prepared(query: query)
        
        XCTAssertWillThrow(Status.range) {
            try statement.bind(integer: 25, to: 0)
        }
        
        XCTAssertWillThrow(Status.range) {
            try statement.bind(double: 25, to: 0)
        }
        
        XCTAssertWillThrow(Status.range) {
            try statement.bind(string: "25", to: 0)
        }
        
        XCTAssertWillThrow(Status.range) {
            try statement.bind(blob: Data(), to: 0)
        }
        
        XCTAssertWillThrow(Status.range) {
            try statement.bindNull(to: 0)
        }
    }
    
    func testBindInvalidGenericParameters() {
        let query     = "SELECT * FROM animal WHERE name = ?"
        let statement = SQLite3.prepared(query: query)
        
        XCTAssertWillThrow(Statement.Error.invalidType) {
            let array = [13]
            try statement.bind(array, to: 0)
        }
    }
    
    // ----------------------------------
    //  MARK: - Step -
    //
    func testStepResultRow() {
        let query     = "SELECT * FROM animal"
        let statement = SQLite3.prepared(query: query)
        
        XCTAssertWontThrow {
            let result = try statement.step()
            XCTAssertEqual(result, .row)
        }
    }
    
    func testStepResultDone() {
        let query     = "INSERT INTO animal (name, type) VALUES (?, ?)"
        let statement = SQLite3.prepared(query: query)
        
        XCTAssertWontThrow {
            try statement.bind(string: "hedgehog", to: 0)
            try statement.bind(string: "rodent",   to: 1)
            let result = try statement.step()
            XCTAssertEqual(result, .done)
        }
    }
    
    func testStepError() {
        let query     = "ROLLBACK;"
        let statement = SQLite3.prepared(query: query)
        
        XCTAssertWillThrow(Status.error) {
            _ = try statement.step()
        }
        
        XCTAssertWillThrow(Status.error) {
            try statement.reset()
        }
    }
    
    func testStepIterateRows() {
        let statement = SQLite3.prepared(query: "SELECT id, name FROM animal WHERE type = 'reptile' ORDER BY id ASC")
        
        XCTAssertWontThrow {
            var names = [String]()
            try statement.stepRows { result, row in
                if let name = row.string(at: 1) {
                    names.append(name)
                }
            }
            XCTAssertEqual(names, ["aligator", "crocodile", "iguana"])
        }
    }
    
    func testStepIterateDictionaries() {
        let statement = SQLite3.prepared(query: "SELECT * FROM animal WHERE id = 3")
        
        XCTAssertWontThrow {
            var dictionaries = [[String: Any]]()
            try statement.stepDictionaries { result, dictionary in
                dictionaries.append(dictionary)
            }
            
            XCTAssertEqual(dictionaries.count, 1)
            let dictionary = dictionaries[0]
            
            XCTAssertEqual(dictionary["id"]     as! Int,    3)
            XCTAssertEqual(dictionary["type"]   as! String, "mammal")
            XCTAssertEqual(dictionary["length"] as! Double, 4279.281)
            XCTAssertEqual(dictionary["image"]  as! Data,   Data(bytes: [0xfe, 0xed, 0xbe, 0xef]))
            
        }
    }
    
    // ----------------------------------
    //  MARK: - Reset -
    //
    func testReset() {
        let query     = "SELECT id FROM animal WHERE id = 1 OR id = 2"
        let statement = SQLite3.prepared(query: query)
        
        _ = try? statement.step()
        
        let id1 = statement.integer(at: 0)
        XCTAssertEqual(id1, 1)
        
        XCTAssertWontThrow {
            try statement.reset()
            _ = try? statement.step()
            
            let id1 = statement.integer(at: 0)
            XCTAssertEqual(id1, 1)
        }
    }
    
    func testResetError() {
        let query     = "ROLLBACK;"
        let statement = SQLite3.prepared(query: query)
        
        _ = try? statement.step()
        
        XCTAssertWillThrow(Status.error) {
            try statement.reset()
        }
    }
    
    func testFinalize() {
        let query     = "SELECT id FROM animal"
        let statement = SQLite3.prepared(query: query)
        
        XCTAssertWontThrow {
            try statement.finalize()
        }
    }
    
    func testFinalizeError() {
        let query     = "ROLLBACK;"
        let statement = SQLite3.prepared(query: query)
        
        _ = try? statement.step()
        
        XCTAssertWillThrow(Status.error) {
            try statement.finalize()
        }
    }
    
    func testClearBindings() {
        let query     = "SELECT * FROM animal WHERE id = ?"
        let statement = SQLite3.prepared(query: query)
        
        try! statement.bind(integer: 3, to: 0)
        
        XCTAssertEqual(statement.expandedQuery, "SELECT * FROM animal WHERE id = 3")
        
        XCTAssertWontThrow {
            try statement.clearBindings()
            
            XCTAssertEqual(statement.expandedQuery, "SELECT * FROM animal WHERE id = NULL")
        }
    }

    // ----------------------------------
    //  MARK: - Columns -
    //
    func testDataCount() {
        let query     = "SELECT * FROM animal WHERE id = 99"
        let statement = SQLite3.prepared(query: query)
        
        try! statement.step()
        
        XCTAssertEqual(statement.dataCount, 0)
        XCTAssertEqual(statement.columnCount, 6)
    }
    
    func testColumnCount() {
        let query     = "SELECT * FROM animal"
        let statement = SQLite3.prepared(query: query)
        
        if case .row = try! statement.step() {
            XCTAssertEqual(statement.columnCount, 6)
        } else {
            XCTFail()
        }
    }
    
    func testColumnNames() {
        let query     = "SELECT * FROM animal WHERE id = 3"
        let statement = SQLite3.prepared(query: query)
        
        if case .row = try! statement.step() {
            XCTAssertEqual(statement.columnName(at: 0), "id")
            XCTAssertEqual(statement.columnName(at: 1), "name")
            XCTAssertEqual(statement.columnName(at: 2), "type")
            XCTAssertEqual(statement.columnName(at: 3), "length")
            XCTAssertEqual(statement.columnName(at: 4), "image")
            XCTAssertEqual(statement.columnName(at: 5), "thumb")
        } else {
            XCTFail()
        }
    }
    
    func testColumnTypes() {
        let query     = "SELECT * FROM animal WHERE id = 3"
        let statement = SQLite3.prepared(query: query)
        
        if case .row = try! statement.step() {
            XCTAssertEqual(statement.columnType(at: 0), .integer)
            XCTAssertEqual(statement.columnType(at: 1), .null)
            XCTAssertEqual(statement.columnType(at: 2), .text)
            XCTAssertEqual(statement.columnType(at: 3), .float)
            XCTAssertEqual(statement.columnType(at: 4), .blob)
            XCTAssertEqual(statement.columnType(at: 5), .null)
        } else {
            XCTFail()
        }
    }
    
    func testColumnByteCount() {
        let query     = "SELECT image FROM animal WHERE id = 3"
        let statement = SQLite3.prepared(query: query)
        
        if case .row = try! statement.step() {
            let byteCount = statement.columnByteCount(at: 0)
            XCTAssertEqual(byteCount, 4)
        } else {
            XCTFail()
        }
    }
    
    func testColumnValues() {
        let query     = "SELECT * FROM animal WHERE id = 3"
        let statement = SQLite3.prepared(query: query)
        
        if case .row = try! statement.step() {
            XCTAssertEqual(statement.integer(at: 0), 3)
            XCTAssertEqual(statement.string(at: 1),  nil)
            XCTAssertEqual(statement.string(at: 2),  "mammal")
            XCTAssertEqual(statement.double(at: 3),  4279.281)
            XCTAssertEqual(statement.blob(at: 4),    Data(bytes: [0xfe, 0xed, 0xbe, 0xef])) // feedbeef
            XCTAssertEqual(statement.blob(at: 5),    nil)
        } else {
            XCTFail()
        }
    }
    
    func testColumnGenericValues() {
        let query     = "SELECT * FROM animal WHERE id = 3"
        let statement = SQLite3.prepared(query: query)
        
        let name:  String? = nil
        let thumb: Data?   = nil
        
        if case .row = try! statement.step() {
            
            XCTAssertEqual(try statement.value(at: 0), true)
            
            XCTAssertEqual(try statement.value(at: 0), 3 as Int)
            XCTAssertEqual(try statement.value(at: 0), 3 as Int8)
            XCTAssertEqual(try statement.value(at: 0), 3 as Int16)
            XCTAssertEqual(try statement.value(at: 0), 3 as Int32)
            XCTAssertEqual(try statement.value(at: 0), 3 as Int64)
            
            XCTAssertEqual(try statement.value(at: 0), 3 as UInt)
            XCTAssertEqual(try statement.value(at: 0), 3 as UInt8)
            XCTAssertEqual(try statement.value(at: 0), 3 as UInt16)
            XCTAssertEqual(try statement.value(at: 0), 3 as UInt32)
            XCTAssertEqual(try statement.value(at: 0), 3 as UInt64)
            
            XCTAssertEqual(try statement.value(at: 1), name)
            XCTAssertEqual(try statement.value(at: 2), "mammal")
            
            XCTAssertEqual(try statement.value(at: 3), 4279.281 as Float)
            XCTAssertEqual(try statement.value(at: 3), 4279.281 as Double)
            
            XCTAssertEqual(try statement.value(at: 4), Data(bytes: [0xfe, 0xed, 0xbe, 0xef])) // feedbeef
            XCTAssertEqual(try statement.value(at: 5), thumb)
        } else {
            XCTFail()
        }
    }
    
    func testColumnInvalidGenericValues() {
        let query     = "SELECT * FROM animal WHERE id = 3"
        let statement = SQLite3.prepared(query: query)
        
        if case .row = try! statement.step() {
            XCTAssertWillThrow(Statement.Error.invalidType) {
                let _: [Int]? = try statement.value(at: 0)
            }
        } else {
            XCTFail()
        }
    }
    
    // ----------------------------------
    //  MARK: - Column Metadata -
    //
    func testColumnMetadata() {
        let query     = "SELECT id as identifier FROM animal WHERE id = 3"
        let statement = SQLite3.prepared(query: query)
        
        XCTAssertEqual(statement.columnDatabaseName(at: 0), "main")
        XCTAssertEqual(statement.columnTableName(at: 0),    "animal")
        
        XCTAssertEqual(statement.columnName(at: 0),       "identifier")
        XCTAssertEqual(statement.columnOriginName(at: 0), "id")
    }
    
    func testColumnMetadataInvalid() {
        let query     = "SELECT id as identifier FROM animal WHERE id = 3"
        let statement = SQLite3.prepared(query: query)
        
        XCTAssertNil(statement.columnDatabaseName(at: 99))
        XCTAssertNil(statement.columnTableName(at: 99))
        XCTAssertNil(statement.columnOriginName(at: 99))
    }
}
