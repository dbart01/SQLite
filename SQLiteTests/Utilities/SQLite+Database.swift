//
//  SQLite+Database.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-03-20.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import SQLite

extension SQLite3 {
    
    static let localURL: URL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("test.sqlite")
    
    static func local() -> SQLite3 {
        return try! SQLite3(location: .disk(SQLite3.localURL))
    }
    
    static func inMemory() -> SQLite3 {
        return try! SQLite3(location: .memory)
    }
    
    static func prepared(query: String, configuration: ((SQLite3) -> Void)? = nil) -> Statement {
        let sqlite = self.local()
        configuration?(sqlite)
        
        return try! sqlite.prepare(query: query)
    }
}
