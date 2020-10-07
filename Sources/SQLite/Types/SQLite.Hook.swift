//
//  SQLite.Hook.swift
//  SQLite
//
//  Created by Dima Bart on 2018-03-28.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation
import sqlite3

extension SQLite {
    public class Hook {
        
        public typealias Update    = (_ action: Action, _ database: String, _ table: String, _ rowID: Int) -> Void
        public typealias Commit    = () -> Bool
        public typealias Rollback  = () -> Void
        public typealias Preupdate = (_ action: Action, _ database: String, _ table: String, _ oldRowID: Int, _ newRowID: Int) -> Void
        public typealias Wal       = (_ database: String, _ pageCount: Int) -> Status
        
        private let sqlite: _SQLite
        
        // MARK: - Init -

        internal init(sqlite: _SQLite) {
            self.sqlite = sqlite
        }
        
        deinit {
            self.update    = nil
            self.commit    = nil
            self.rollback  = nil
            self.preupdate = nil
            self.wal       = nil
        }
        
        // MARK: - Hooks -

        public var update: Handler<Update>? {
            didSet {
                if let _ = self.update {
                    self.registerUpdateHook()
                } else {
                    self.unregisterUpdateHook()
                }
            }
        }
        
        public var commit: Handler<Commit>? {
            didSet {
                if let _ = self.commit {
                    self.registerCommitHook()
                } else {
                    self.unregisterCommitHook()
                }
            }
        }
        
        public var rollback: Handler<Rollback>? {
            didSet {
                if let _ = self.rollback {
                    self.registerRollbackHook()
                } else {
                    self.unregisterRollbackHook()
                }
            }
        }
        
        public var preupdate: Handler<Preupdate>? {
            didSet {
                if let _ = self.preupdate {
                    self.registerPreupdateHook()
                } else {
                    self.unregisterPreupdateHook()
                }
            }
        }
        
        public var wal: Handler<Wal>? {
            didSet {
                if let _ = self.wal {
                    self.registerWalHook()
                } else {
                    self.unregisterWalHook()
                }
            }
        }
        
        // MARK: - Registration -

        private func registerUpdateHook() {
            sqlite3_update_hook(self.sqlite, { context, action, database, table, rowID in
                context!.hook.update!.callback(action.action, database!.string, table!.string, Int(rowID))
            }, self.pointer)
        }
        
        private func registerCommitHook() {
            sqlite3_commit_hook(self.sqlite, { context in
                return context!.hook.commit!.callback() ? 0 : 1
            }, self.pointer)
        }
        
        private func registerRollbackHook() {
            sqlite3_rollback_hook(self.sqlite, { context in
                context!.hook.rollback!.callback()
            }, self.pointer)
        }
        
        private func registerPreupdateHook() {
            sqlite3_preupdate_hook(self.sqlite, { (context, sqlite, action, database, table, oldRowID, newRowID) in
                context!.hook.preupdate!.callback(action.action, database!.string, table!.string, Int(oldRowID), Int(newRowID))
            }, self.pointer)
        }
        
        private func registerWalHook() {
            sqlite3_wal_hook(self.sqlite, { (context, sqlite, database, pageCount) -> Int32 in
                return context!.hook.wal!.callback(database!.string, Int(pageCount)).rawValue
            }, self.pointer)
        }
        
        // MARK: - Registration -

        private func unregisterUpdateHook() {
            sqlite3_update_hook(self.sqlite, nil, nil)
        }
        
        private func unregisterCommitHook() {
            sqlite3_commit_hook(self.sqlite, nil, nil)
        }
        
        private func unregisterRollbackHook() {
            sqlite3_rollback_hook(self.sqlite, nil, nil)
        }
        
        private func unregisterPreupdateHook() {
            sqlite3_preupdate_hook(self.sqlite, nil, nil)
        }
        
        private func unregisterWalHook() {
            sqlite3_wal_hook(self.sqlite, nil, nil)
        }
    }
}

// MARK: - Handler -

extension SQLite.Hook {
    public struct Handler<T> {
        let callback: T
    }
}

// MARK: - UnsafeMutableRawPointer -

private extension UnsafeMutableRawPointer {
    var hook: SQLite.Hook {
        return Unmanaged<SQLite.Hook>.fromOpaque(self).takeUnretainedValue()
    }
}

private extension SQLite.Hook {
    var pointer: UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(self).toOpaque()
    }
}
