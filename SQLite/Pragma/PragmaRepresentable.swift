//
//  PragmaRepresentable.swift
//  SQLite
//
//  Created by Dima Bart on 2018-03-26.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

public protocol PragmaRepresentable: RawRepresentable {
    var sqlValue: String { get }
}

extension PragmaRepresentable where Self == RawValue {
    
    public var sqlValue: String {
        return "\(self)"
    }
    
    public var rawValue: Self.RawValue {
        return self
    }
    
    public init?(rawValue: Self.RawValue) {
        self = rawValue
    }
}

extension Int: PragmaRepresentable {
    public typealias RawValue = Int
}

extension String: PragmaRepresentable {
    public typealias RawValue = String
}
