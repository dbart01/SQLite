//
//  Function.Description.swift
//  SQLite
//
//  Created by Dima Bart on 2018-04-05.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension Function {
    public struct Description: Hashable {
        
        public let name:          String
        public let arguments:     ArgCount
        public let encoding:      Encoding
        public let deterministic: Bool
        
        // MARK: - Init -

        public init(name: String, arguments: ArgCount, encoding: Encoding = .utf8, deterministic: Bool = true) {
            self.name          = name
            self.arguments     = arguments
            self.encoding      = encoding
            self.deterministic = deterministic
        }
    }
}
