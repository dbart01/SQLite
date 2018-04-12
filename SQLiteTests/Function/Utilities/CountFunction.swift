//
//  CountFunction.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-10.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

@testable import SQLite

class CountFunction: Function.Aggregate<Int> {
    override func step(context: Context, arguments: [Value], container: inout Int) {
        container += 1
    }
    
    override func final(context: Context, container: Int?) {
        context.bind(container ?? -1)
    }
}

extension Int: Aggregatable {
    public static func initialize() -> Int {
        return 0
    }
}
