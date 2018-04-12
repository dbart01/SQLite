//
//  BlockFunction.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-11.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

@testable import SQLite

class BlockFunction: Function.Scalar {
    
    typealias Block = (_ context: Context, _ arguments: [Value]) -> Void
    
    let block: Block
    
    // ----------------------------------
    //  MARK: - Init -
    //
    init(sqlite: SQLite, description: Function.Description, block: @escaping Block) throws {
        self.block = block
        
        try super.init(sqlite: sqlite, description: description)
    }
    
    // ----------------------------------
    //  MARK: - Scalar -
    //
    override func main(context: Context, arguments: [Value]) {
        self.block(context, arguments)
    }
}
