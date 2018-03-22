//
//  SQLite3+Codable.swift
//  SQLite MacOS
//
//  Created by Dima Bart on 2018-03-21.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension SQLite3 {
    
    public func insert<T: Encodable>(into table: String, value encodable: T) throws -> Statement.Result {
        let encoder = JSONEncoder()
        let data    = try encoder.encode(encodable)
        let json    = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
        let keys         = json.keys.map { $0 }
        let values       = json.values.map { _ in return "?" }
        let keysString   = keys.joined(separator: ",")
        let valuesString = values.joined(separator: ",")
        
        let sql       = "INSERT INTO \(table) (\(keysString)) VALUES (\(valuesString))"
        let statement = try self.prepare(query: sql)
        
        try json.values.enumerated().forEach { index, value in
            try statement.bind(value, to: index)
        }
        
        return try statement.step()
    }
}
