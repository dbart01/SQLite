//
//  SQLite.Backup.swift
//  SQLite
//
//  Created by Dima Bart on 2018-04-03.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation
import sqlite3

typealias _Backup = OpaquePointer

extension SQLite {
    public class Backup {
        
        public typealias ProgressHandler = (_ total: Int, _ remaining: Int) -> Void
        
        public let sourceSqlite:      SQLite
        public let destinationSqlite: SQLite
        
        public let sourceName:        String
        public let destinationName:   String

        private let backup: _Backup
        
        // ----------------------------------
        //  MARK: - Init -
        //
        public init(from sourceSqlite: SQLite, sourceName: String = "main", to destinationSqlite: SQLite, destinationName: String = "main") throws {
            self.sourceSqlite      = sourceSqlite
            self.destinationSqlite = destinationSqlite
            self.sourceName        = sourceName
            self.destinationName   = destinationName
            
            guard let backup = sqlite3_backup_init(destinationSqlite.sqlite, destinationName, sourceSqlite.sqlite, sourceName) else {
                throw destinationSqlite.errorStatus
            }
            
            self.backup = backup
        }
        
        deinit {
            let status = sqlite3_backup_finish(self.backup).status
            if status != .ok {
                print("Failed to close backup: \(status.description)")
            }
        }
        
        // ----------------------------------
        //  MARK: - Copy -
        //
        public func copy(pages: Int, progressHandler: ProgressHandler? = nil) throws -> Status {
            let status = sqlite3_backup_step(self.backup, Int32(pages)).status
            guard status == .ok || status == .done else {
                throw status
            }
            
            if let progressHandler = progressHandler {
                let total     = Int(sqlite3_backup_pagecount(self.backup))
                let remaining = Int(sqlite3_backup_remaining(self.backup))                
                progressHandler(total, remaining)
            }
            
            return status
        }
    }
}
