//
//  SQLite+CodableTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-21.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
import SQLite

class SQLite_CodableTests: XCTestCase {

    
    func testCodableInsert() {
        let sqlite = SQLite.inMemory()
        
        let query = """
        CREATE TABLE IF NOT EXISTS animal (
            id   INTEGER PRIMARY KEY ASC,
            name TEXT,
            type TEXT
        );
        """
        
        _ = try! sqlite.execute(query: query)
        
        let animal = Animal(
            id:   13,
            name: "Aligator",
            type: "reptile"
        )
        
        let result = try! sqlite.insert(into: "animal", value: animal)
        
        XCTAssertEqual(result, .done)
    }
}

private class Animal: Codable {
    
    let id:     Int
    let name:   String
    let type:   String
    
    init(id: Int, name: String, type: String) {
        self.id   = id
        self.name = name
        self.type = type
    }
}
