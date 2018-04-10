//
//  Function.swift
//  SQLite
//
//  Created by Dima Bart on 2018-04-05.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

open class Function {
        
    public let description: Description
    public let sqlite:      SQLite
    
    // ----------------------------------
    //  MARK: - Init -
    //
    internal init(description: Description, sqlite: SQLite) throws {
        self.description = description
        self.sqlite      = sqlite
    }
    
    deinit {
        let status = sqlite3_create_function_v2(
            /* 1 */ sqlite.sqlite,
            /* 2 */ description.name,
            /* 3 */ Int32(description.arguments.integerValue),
            /* 4 */ description.encoding.rawValue,
            /* 5 */ nil,
            /* 6 */ nil,
            /* 7 */ nil,
            /* 8 */ nil,
            /* 9 */ nil
        ).status

        if status != .ok {
            print("Failed to deallocate user-defined function: \(self.description.name)")
        }
    }
}
