//
//  Pragma.swift
//  SQLite
//
//  Created by Dima Bart on 2018-03-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

public enum Pragma {
    public static let foreignKeys   = PragmaDescription(key: "foreign_keys",   type: Boolean.self)
    public static let applicationID = PragmaDescription(key: "application_id", type: Int.self)
    public static let encoding      = PragmaDescription(key: "encoding",       type: Encoding.self)
    public static let cacheSize     = PragmaDescription(key: "cache_size",     type: CacheSize.self)
    public static let journalMode   = PragmaDescription(key: "journal_mode",   type: JournalMode.self)
}

public struct PragmaDescription<T> where T: PragmaRepresentable {
    
    public let key:  String
    public let type: T.Type
    
    // MARK: - Init -

    fileprivate init(key: String, type: T.Type) {
        self.key  = key
        self.type = type
    }
}
