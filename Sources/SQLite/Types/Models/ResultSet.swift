//
//  ResultSet.swift
//  SQLite
//
//  Created by Dima Bart on 2018-04-13.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation
import sqlite3

public typealias Row = [String : Any?]

public class ResultSet: Sequence {
    
    public typealias Iterator = AnyIterator<Row>
    
    internal let statement: Statement
    
    // MARK: - Init -

    internal init(statement: Statement) {
        self.statement = statement
    }
    
    // MARK: - Sequence -

    public func makeIterator() -> AnyIterator<Row> {
        do {
            try self.statement.reset()
        } catch {
            self.statementResetFailed()
        }
        return AnyIterator(SequentialIterator(statement: self.statement))
    }
    
    internal func statementResetFailed() {
        print("Failed to reset prepared statement before sequence iteration. Undefined results may follow.")
    }
}

// MARK: - SequentialIterator -

extension ResultSet {
    internal struct SequentialIterator: IteratorProtocol {
        
        let statement: Statement
        
        // MARK: - Init -

        internal init(statement: Statement) {
            self.statement = statement
        }
        
        // MARK: - IteratorProtocol -

        typealias Element = Row
        
        mutating func next() -> Element? {
            do {
                let result = try self.statement.step()
                switch result {
                case .row:
                    return self.statement.dictionaryRepresentationForRow()
                case .done:
                    return nil
                }
                
            } catch {
                return nil
            }
        }
    }
}
