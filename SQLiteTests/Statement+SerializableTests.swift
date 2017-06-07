//
//  Statement+SerializableTests.swift
//  SQLite
//
//  Created by Dima Bart on 2017-06-05.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import XCTest
import SQLite

class Statement_SerializableTests: XCTestCase {

    // ----------------------------------
    //  MARK: - Serializable -
    //
    func testBindSerializable() {
        let query     = "INSERT INTO animal (id, name, type, length, image) VALUES (?, ?, ?, ?, ?)"
        let statement = prepared(query: query)
        
        let data = Data(bytes: [0xbe, 0xee])
        
        XCTAssertWontThrow {
            try statement.bind(serializable: 100,   to: 0)
            try statement.bind(serializable: "bee", to: 1)
            try statement.bind(serializable: nil,   to: 2)
            try statement.bind(serializable: 0.87,  to: 3)
            try statement.bind(serializable: data,  to: 4)
            
            let expanded = "INSERT INTO animal (id, name, type, length, image) VALUES (100, 'bee', NULL, 0.87, x'beee')"
            XCTAssertEqual(statement.expandedQuery, expanded)
            XCTAssertEqual(statement.query, query)
            
        }
    }
    
    // ----------------------------------
    //  MARK: - Step -
    //
    func testStepThroughRows() {
        let statement = prepared(query: "SELECT id, name FROM animal WHERE type = 'reptile' ORDER BY id ASC")
        
        XCTAssertWontThrow {
            var names = [String]()
            try statement.stepRows { row in
                if let name = row.string(at: 1) {
                    names.append(name)
                }
            }
            XCTAssertEqual(names, ["aligator", "crocodile", "iguana"])
        }
    }
    
    func testStepThroughDictionary() {
        let statement = prepared(query: "SELECT * FROM animal WHERE id = 3")
        
        XCTAssertWontThrow {
            var dictionaries = [[String: Any]]()
            try statement.stepDictionary { dictionary in
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
}
