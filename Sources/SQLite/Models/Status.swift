//
//  Status.swift
//  SQLite
//
//  Created by Dima Bart on 2017-05-22.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation
import sqlite3

public enum Status: RawRepresentable, Error, CustomStringConvertible, CustomDebugStringConvertible {
    
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
    
    public typealias RawValue = Int32
    
    public var rawValue: RawValue {
        switch self {
        case .ok:          return SQLITE_OK
        case .error:       return SQLITE_ERROR
        case .internal:    return SQLITE_INTERNAL
        case .permission:  return SQLITE_PERM
        case .abort:       return SQLITE_ABORT
        case .busy:        return SQLITE_BUSY
        case .locked:      return SQLITE_LOCKED
        case .noMemory:    return SQLITE_NOMEM
        case .readOnly:    return SQLITE_READONLY
        case .interrupt:   return SQLITE_INTERRUPT
        case .ioError:     return SQLITE_IOERR
        case .corrupt:     return SQLITE_CORRUPT
        case .notFound:    return SQLITE_NOTFOUND
        case .full:        return SQLITE_FULL
        case .cantOpen:    return SQLITE_CANTOPEN
        case .protocol:    return SQLITE_PROTOCOL
        case .empty:       return SQLITE_EMPTY
        case .schema:      return SQLITE_SCHEMA
        case .tooBig:      return SQLITE_TOOBIG
        case .constraint:  return SQLITE_CONSTRAINT
        case .mismatch:    return SQLITE_MISMATCH
        case .misuse:      return SQLITE_MISUSE
        case .noLFS:       return SQLITE_NOLFS
        case .auth:        return SQLITE_AUTH
        case .format:      return SQLITE_FORMAT
        case .range:       return SQLITE_RANGE
        case .notDatabase: return SQLITE_NOTADB
        case .notice:      return SQLITE_NOTICE
        case .warning:     return SQLITE_WARNING
        case .row:         return SQLITE_ROW
        case .done:        return SQLITE_DONE
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case type(of: self).ok.rawValue:           self = .ok
        case type(of: self).error.rawValue:        self = .error
        case type(of: self).internal.rawValue:     self = .internal
        case type(of: self).permission.rawValue:   self = .permission
        case type(of: self).abort.rawValue:        self = .abort
        case type(of: self).busy.rawValue:         self = .busy
        case type(of: self).locked.rawValue:       self = .locked
        case type(of: self).noMemory.rawValue:     self = .noMemory
        case type(of: self).readOnly.rawValue:     self = .readOnly
        case type(of: self).interrupt.rawValue:    self = .interrupt
        case type(of: self).ioError.rawValue:      self = .ioError
        case type(of: self).corrupt.rawValue:      self = .corrupt
        case type(of: self).notFound.rawValue:     self = .notFound
        case type(of: self).full.rawValue:         self = .full
        case type(of: self).cantOpen.rawValue:     self = .cantOpen
        case type(of: self).protocol.rawValue:     self = .protocol
        case type(of: self).empty.rawValue:        self = .empty
        case type(of: self).schema.rawValue:       self = .schema
        case type(of: self).tooBig.rawValue:       self = .tooBig
        case type(of: self).constraint.rawValue:   self = .constraint
        case type(of: self).mismatch.rawValue:     self = .mismatch
        case type(of: self).misuse.rawValue:       self = .misuse
        case type(of: self).noLFS.rawValue:        self = .noLFS
        case type(of: self).auth.rawValue:         self = .auth
        case type(of: self).format.rawValue:       self = .format
        case type(of: self).range.rawValue:        self = .range
        case type(of: self).notDatabase .rawValue: self = .notDatabase
        case type(of: self).notice .rawValue:      self = .notice
        case type(of: self).warning .rawValue:     self = .warning
        case type(of: self).row .rawValue:         self = .row
        case type(of: self).done .rawValue:        self = .done
        default:
            return nil
        }
    }
    
    public var debugDescription: String {
        return self.description
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
        return Status(rawValue: self)!
    }
}
