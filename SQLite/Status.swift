//
//  Status.swift
//  SQLite
//
//  Created by Dima Bart on 2017-05-22.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

public enum Status: Error, CustomStringConvertible, CustomDebugStringConvertible {
    
    case ok
    case error
    case `internal`
    case permission
    case abort
    case busy
    case locked
    case noMemory
    case readOnly
    case interrupt
    case ioError
    case corrupt
    case notFound
    case full
    case cantOpen
    case `protocol`
    case empty
    case schema
    case tooBig
    case constraint
    case mismatch
    case misuse
    case noLFS
    case auth
    case format
    case range
    case notDatabase
    case notice
    case warning
    case row
    case done
    
    public init(_ code: Int32) {
        switch code {
        case SQLITE_OK:         self = .ok
        case SQLITE_ERROR:      self = .error
        case SQLITE_INTERNAL:   self = .internal
        case SQLITE_PERM:       self = .permission
        case SQLITE_ABORT:      self = .abort
        case SQLITE_BUSY:       self = .busy
        case SQLITE_LOCKED:     self = .locked
        case SQLITE_NOMEM:      self = .noMemory
        case SQLITE_READONLY:   self = .readOnly
        case SQLITE_INTERRUPT:  self = .interrupt
        case SQLITE_IOERR:      self = .ioError
        case SQLITE_CORRUPT:    self = .corrupt
        case SQLITE_NOTFOUND:   self = .notFound
        case SQLITE_FULL:       self = .full
        case SQLITE_CANTOPEN:   self = .cantOpen
        case SQLITE_PROTOCOL:   self = .protocol
        case SQLITE_EMPTY:      self = .empty
        case SQLITE_SCHEMA:     self = .schema
        case SQLITE_TOOBIG:     self = .tooBig
        case SQLITE_CONSTRAINT: self = .constraint
        case SQLITE_MISMATCH:   self = .mismatch
        case SQLITE_MISUSE:     self = .misuse
        case SQLITE_NOLFS:      self = .noLFS
        case SQLITE_AUTH:       self = .auth
        case SQLITE_FORMAT:     self = .format
        case SQLITE_RANGE:      self = .range
        case SQLITE_NOTADB:     self = .notDatabase 
        case SQLITE_NOTICE:     self = .notice 
        case SQLITE_WARNING:    self = .warning 
        case SQLITE_ROW:        self = .row 
        case SQLITE_DONE:       self = .done 
        default:
            fatalError("Unrecognized SQLite error code: \(code)")
        }
    }
    
    public var debugDescription: String {
        return description
    }
    
    public var description: String {
        switch self {
        case .ok:          return "ok: Successful result"
        case .error:       return "error: SQL error or missing database"
        case .internal:    return "internal: Internal logic error in SQLite"
        case .permission:  return "permission: Access permission denied"
        case .abort:       return "abort: Callback routine requested an abort"
        case .busy:        return "busy: The database file is locked"
        case .locked:      return "locked: A table in the database is locked"
        case .noMemory:    return "noMemory: A malloc() failed"
        case .readOnly:    return "readOnly: Attempt to write a readonly database"
        case .interrupt:   return "interrupt: Operation terminated by sqlite3_interrupt("
        case .ioError:     return "ioError: Some kind of disk I/O error occurred"
        case .corrupt:     return "corrupt: The database disk image is malformed"
        case .notFound:    return "notFound: Unknown opcode in sqlite3_file_control()"
        case .full:        return "full: Insertion failed because database is full"
        case .cantOpen:    return "cantOpen: Unable to open the database file"
        case .protocol:    return "protocol: Database lock protocol error"
        case .empty:       return "empty: Database is empty"
        case .schema:      return "schema: The database schema changed"
        case .tooBig:      return "tooBig: String or BLOB exceeds size limit"
        case .constraint:  return "constraint: Abort due to constraint violation"
        case .mismatch:    return "mismatch: Data type mismatch"
        case .misuse:      return "misuse: Library used incorrectly"
        case .noLFS:       return "noLFS: Uses OS features not supported on host"
        case .auth:        return "auth: Authorization denied"
        case .format:      return "format: Auxiliary database format error"
        case .range:       return "range: 2nd parameter to sqlite3_bind out of range"
        case .notDatabase: return "notDatabase: File opened that is not a database file"
        case .notice:      return "notice: Notifications from sqlite3_log()"
        case .warning:     return "warning: Warnings from sqlite3_log()"
        case .row:         return "row: sqlite3_step() has another row ready"
        case .done:        return "done: sqlite3_step() has finished executing"
        }
    }
}

extension Int32 {
    var status: Status {
        return Status(self)
    }
}
