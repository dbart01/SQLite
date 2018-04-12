//
//  String+Name.swift
//  SQLiteTests
//
//  Created by Dima Bart on 2018-04-10.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension String {
    
    static var ultraLongName: String {
        var container = ""
        for _ in 0..<100 {
            container += "abcdefghijklmnop"
        }
        return container
    }
}
