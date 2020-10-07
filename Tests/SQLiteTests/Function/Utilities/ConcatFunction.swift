//
//  ConcatFunction.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-10.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

@testable import SQLite

class ConcatFunction: Function.Aggregate<String> {
    override func step(context: Context, arguments: [Value], container: inout String) {
        container += arguments[0].string ?? ""
    }
    
    override func final(context: Context, container: String?) {
        context.bind(container ?? "")
    }
}

extension String: Aggregatable {
    public static func initialize() -> String {
        return ""
    }
}
