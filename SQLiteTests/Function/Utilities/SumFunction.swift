//
//  SumFunction.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-10.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

@testable import SQLite

class SumFunction: Function.Aggregate<SumFunction.Aggregator> {
    
    override func step(context: Context, arguments: [Value], container: inout Aggregator) {
        container.sum += arguments[0].integer
    }
    
    override func final(context: Context, container: Aggregator?) {
        context.bind(container?.sum ?? -1)
    }
}

extension SumFunction {
    final class Aggregator: Aggregatable {
        
        fileprivate(set) var sum: Int = 0
        
        static func initialize() -> Aggregator {
            return Aggregator()
        }
        
        init() {}
        
        deinit {
            print("Aggregator deinitialized.")
        }
    }
}
