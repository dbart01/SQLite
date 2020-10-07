//
//  SQLite.Transaction.swift
//  SQLite MacOS
//
//  Created by Dima Bart on 2018-03-23.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension SQLite {
    
    public typealias TransactionOperation = () throws -> Transaction.Result
    
    public enum Transaction {
        case deferred
        case immediate
        case exclusive
        
        var sqlRepresentation: String {
            switch self {
            case .deferred:  return "DEFERRED"
            case .immediate: return "IMMEDIATE"
            case .exclusive: return "EXCLUSIVE"
            }
        }
    }
}

// MARK: - Transaction.Result -

extension SQLite.Transaction {
    public enum Result {
        case commit
        case rollback
    }
}
