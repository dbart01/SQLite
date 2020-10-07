//
//  Aggregatable.swift
//  SQLite MacOS
//
//  Created by Dima Bart on 2018-04-06.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

public protocol Aggregatable {
    static func initialize() -> Self
}
