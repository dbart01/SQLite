//
//  DoubleFunction.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-10.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

@testable import SQLite

class DoubleFunction: Function.Scalar {

    override func main(context: Context, arguments: [Value]) {
        context.bind(Double(arguments[0].integer * 2))
    }
}
