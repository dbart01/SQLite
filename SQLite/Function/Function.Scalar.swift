//
//  Function.Scalar.swift
//  SQLite
//
//  Created by Dima Bart on 2018-04-05.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension Function {
    open class Scalar: Function {
        
        // ----------------------------------
        //  MARK: - Init -
        //
        internal override init(description: Description, sqlite: SQLite) throws {
            try super.init(description: description, sqlite: sqlite)
            
            let status = sqlite3_create_function_v2(
                /* 1 */ sqlite.sqlite,
                /* 2 */ description.name,
                /* 3 */ Int32(description.arguments.integerValue),
                /* 4 */ description.encoding.rawValue,
                /* 5 */ self.pointer,
                /* 6 */ { (context: _Context?, argc, argv: UnsafeMutablePointer<_Value?>?) in
                    sqlite3_user_data(context).function.main(
                        context:   Context(context: context!),
                        arguments: Value.collection(argc: Int(argc), argv: argv!)
                    )
                },
                /* 7 */ nil,
                /* 8 */ nil,
                /* 9 */ nil
            ).status
        
            guard status == .ok else {
                throw status
            }
        }
        
        // ----------------------------------
        //  MARK: - API -
        //
        open func main(context: Context, arguments: [Value]) {
            // Subclass override
        }
    }
}

// ----------------------------------
//  MARK: - Function -
//
private extension UnsafeMutableRawPointer {
    var function: Function.Scalar {
        return Unmanaged<Function.Scalar>.fromOpaque(self).takeUnretainedValue()
    }
}

private extension Function.Scalar {
    var pointer: UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(self).toOpaque()
    }
}
