//
//  Function.ContextTests.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-11.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import XCTest
@testable import SQLite

class Function_ContextTests: XCTestCase {
    
    private let functionDescription: Function.Description = .init(
        name:          "xct_func",
        arguments:     .finite(1),
        encoding:      .utf8,
        deterministic: true
    )

    // ----------------------------------
    //  MARK: - Init -
    //
    func testInit() {
        let sqlite   = SQLite.default()
        let function = try! BlockFunction(sqlite: sqlite, description: self.functionDescription, block: { ctx, args in
            
            let context = Function.Context(context: ctx.context)
            XCTAssertTrue(context.context == ctx.context)
        })
        try! sqlite.execute(query: "SELECT xct_func(1) as result")
        _ = function
    }
    
    // ----------------------------------
    //  MARK: - Generic -
    //
    func testGenericBool() {
        self.execute(function: { $0.bind(true)  }, handler: { XCTAssertEqual($0 as! Int, 1) })
        self.execute(function: { $0.bind(false) }, handler: { XCTAssertEqual($0 as! Int, 0) })
    }
    
    func testGenericInteger() {
        self.execute(function: { $0.bind(13 as Int) },    handler: { XCTAssertEqual($0 as! Int, 13) })
        self.execute(function: { $0.bind(13 as Int8) },   handler: { XCTAssertEqual($0 as! Int, 13) })
        self.execute(function: { $0.bind(13 as Int16) },  handler: { XCTAssertEqual($0 as! Int, 13) })
        self.execute(function: { $0.bind(13 as Int32) },  handler: { XCTAssertEqual($0 as! Int, 13) })
        self.execute(function: { $0.bind(13 as Int64) },  handler: { XCTAssertEqual($0 as! Int, 13) })
        
        self.execute(function: { $0.bind(13 as UInt) },   handler: { XCTAssertEqual($0 as! Int, 13) })
        self.execute(function: { $0.bind(13 as UInt8) },  handler: { XCTAssertEqual($0 as! Int, 13) })
        self.execute(function: { $0.bind(13 as UInt16) }, handler: { XCTAssertEqual($0 as! Int, 13) })
        self.execute(function: { $0.bind(13 as UInt32) }, handler: { XCTAssertEqual($0 as! Int, 13) })
        self.execute(function: { $0.bind(13 as UInt64) }, handler: { XCTAssertEqual($0 as! Int, 13) })
    }
    
    func testGenericString() {
        let value = "http://www.google.com"
        let url = URL(string: value)!
        
        self.execute(function: { $0.bind(value) }, handler: { XCTAssertEqual($0 as! String, value) })
        self.execute(function: { $0.bind(url)  },  handler: { XCTAssertEqual($0 as! String, value) })
    }
    
    func testGenericFloat() {
        self.execute(function: { $0.bind(13.75 as Float)   }, handler: { XCTAssertEqual($0 as! Double, 13.75) })
        self.execute(function: { $0.bind(13.75 as Double)  }, handler: { XCTAssertEqual($0 as! Double, 13.75) })
        self.execute(function: { $0.bind(13.75 as Decimal) }, handler: { XCTAssertEqual($0 as! String, "13.75") })
    }
    
    func testGenericData() {
        let blob = Data(bytes: [0xFE, 0xED, 0xBE, 0xEF])
        self.execute(function: { $0.bind(blob) }, handler: { XCTAssertEqual($0 as! Data, blob) })
    }
    
    func testGenericNil() {
        let value: String? = nil
        self.execute(function: { $0.bind(value) }, handler: { XCTAssertNil($0 as? String) })
    }
    
    func testGenericAny() {
        let tiger:    String? = "tiger"
        let anyTiger: Any     = tiger as Any
        let bear:     String? = nil
        let anyBear:  Any     = bear as Any
        
        self.execute(function: { $0.bind(anyTiger) }, handler: { XCTAssertEqual($0 as? String, "tiger") })
        self.execute(function: { $0.bind(anyBear)  }, handler: { XCTAssertEqual($0 as? String, nil)     })
    }
    
    // ----------------------------------
    //  MARK: - Bind -
    //
    func testInteger() {
        self.execute(function: { context in
            context.bind(integer: 13)
        }, handler: { result in
            XCTAssertEqual(result as! Int, 13)
        })
    }
    
    func testIntegerNull() {
        self.execute(function: { context in
            context.bind(integer: Optional<Int>.none)
        }, handler: { result in
            XCTAssertNil(result)
        })
    }
    
    func testDouble() {
        self.execute(function: { context in
            context.bind(double: 13.0)
        }, handler: { result in
            XCTAssertEqual(result as! Double, 13.0)
        })
    }
    
    func testDoubleNull() {
        self.execute(function: { context in
            context.bind(double: Optional<Double>.none)
        }, handler: { result in
            XCTAssertNil(result)
        })
    }
    
    func testString() {
        self.execute(function: { context in
            context.bind(string: "13.0")
        }, handler: { result in
            XCTAssertEqual(result as! String, "13.0")
        })
    }
    
    func testStringNull() {
        self.execute(function: { context in
            context.bind(string: Optional<String>.none)
        }, handler: { result in
            XCTAssertNil(result)
        })
    }
    
    func testBlob() {
        let blob = Data(bytes: [0xFE, 0xED, 0xBE, 0xEF])
        self.execute(function: { context in
            context.bind(blob: blob)
        }, handler: { result in
            XCTAssertEqual(result as! Data, blob)
        })
    }
    
    func testBlobNull() {
        self.execute(function: { context in
            context.bind(blob: Optional<Data>.none)
        }, handler: { result in
            XCTAssertNil(result)
        })
    }
    
    func testErrors() {
        self.execute(function: { context in
            context.bind(error: .tooBig)
        }, expecting: .tooBig)
        
        self.execute(function: { context in
            context.bind(error: .noMemory)
        }, expecting: .noMemory)
        
        self.execute(function: { context in
            context.bind(error: .message("Something wen't wrong"))
        }, expecting: .error)
        
        self.execute(function: { context in
            context.bind(error: .message("Error"), status: .busy)
        }, expecting: .busy)
    }
    
    // ----------------------------------
    //  MARK: - Utilities -
    //
    private func execute(function: @escaping (Function.Context) -> Void, handler: @escaping (Any?) -> Void) {
        let sqlite   = SQLite.default()
        let function = try! BlockFunction(sqlite: sqlite, description: self.functionDescription, block: { context, args in
            function(context)
        })
        
        try! sqlite.execute(query: "SELECT xct_func(1) as result", dictionaryHandler: { result, dictionary in
            handler(dictionary["result"])
        })
        
        _ = function
    }
    
    private func execute(function: @escaping (Function.Context) -> Void, expecting error: Status) {
        let sqlite   = SQLite.default()
        let function = try! BlockFunction(sqlite: sqlite, description: self.functionDescription, block: { context, args in
            function(context)
        })
        
        XCTAssertWillThrow(error) {
            try sqlite.execute(query: "SELECT xct_func(1) as result")
        }
        
        _ = function
    }
}
