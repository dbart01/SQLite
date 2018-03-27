//
//  Value.swift
//  SQLite
//
//  Created by Dima Bart on 2017-05-30.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

public enum Value {
    case integer(Int?)
    case double(Double?)
    case string(String?)
    case blob(Data?)
}
