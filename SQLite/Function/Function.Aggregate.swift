//
//  Function.Aggregate.swift
//  SQLite
//
//  Created by Dima Bart on 2018-04-05.
//  Copyright © 2018 Dima Bart. All rights reserved.
//

import Foundation

extension Function {
    open class Aggregate<Container>: Function where Container: Aggregatable {
        
        // ----------------------------------
        //  MARK: - Init -
        //
        internal override init(sqlite: SQLite, description: Description) throws {
            try super.init(sqlite: sqlite, description: description)
            
            let status = sqlite3_create_function_v2(
                /* 1 */ sqlite.sqlite,
                /* 2 */ description.name,
                /* 3 */ Int32(description.arguments.integerValue),
                /* 4 */ description.encoding.rawValue,
                /* 5 */ self.pointer,
                /* 6 */ nil,
                /* 7 */ { (context: _Context?, argc, argv: UnsafeMutablePointer<_Value?>?) in
                    sqlite3_user_data(context).function(typed: Placeholder.self)._step(
                        context:   Context(context: context!),
                        arguments: Value.collection(argc: Int(argc), argv: argv!)
                    )
                },
                /* 8 */ { (context: _Context?) in
                    sqlite3_user_data(context).function(typed: Placeholder.self)._final(
                        context: Context(context: context!)
                    )
                },
                /* 9 */ nil
            ).status
        
            guard status == .ok else {
                throw status
            }
        }
        
        // ----------------------------------
        //  MARK: - Private -
        //
        private func _step(context: Context, arguments: [Value]) {
            let bufferSize = Int32(MemoryLayout<Container>.stride)
            let buffer     = sqlite3_aggregate_context(context.context, bufferSize)!
            
            let container: UnsafeMutablePointer<Container>
            if self.isObjectContainer {
                container = buffer.createObjectContainer(typed: Container.self)
            } else {
                container = buffer.createScalarContainer(typed: Container.self)
            }
            self.step(context: context, arguments: arguments, container: &container.pointee)
        }
        
        private func _final(context: Context) {
            let pointer = sqlite3_aggregate_context(context.context, 0)
            self.final(context: context, container: pointer?.existingContainer(typed: Container.self))
            pointer?.deinitialize(typed: Container.self)
        }
        
        private var isObjectContainer: Bool {
            return Container.self is AnyObject.Type
        }
        
        // ----------------------------------
        //  MARK: - API -
        //
        open func step(context: Context, arguments: [Value], container: inout Container) {
            // Subclass override
        }
        
        open func final(context: Context, container: Container?) {
            // Subclass override
        }
    }
}

// ----------------------------------
//  MARK: - Placeholder -
//
private final class Placeholder: Aggregatable {
    static func initialize() -> Placeholder {
        return Placeholder()
    }
    
    init() {}
}

// ----------------------------------
//  MARK: - Function.Container -
//
private extension UnsafeMutableRawPointer {
    
    private func mutablePointer<T>(typed type: T.Type) -> UnsafeMutablePointer<T?> {
        return self.assumingMemoryBound(to: Optional<T>.self)
    }
    
    func createObjectContainer<T>(typed type: T.Type) -> UnsafeMutablePointer<T> where T: Aggregatable {
        let pointer = self.assumingMemoryBound(to: Optional<T>.self)
        if pointer.pointee == nil {
            let container = T.initialize() as AnyObject
            let unmanaged = (Unmanaged.passUnretained(container).takeUnretainedValue() as! T)
            pointer.initialize(to: unmanaged)
        }
        let raw = UnsafeMutableRawPointer(pointer)
        return raw.assumingMemoryBound(to: T.self)
    }
    
    func createScalarContainer<T>(typed type: T.Type) -> UnsafeMutablePointer<T> where T: Aggregatable {
        let pointer = self.mutablePointer(typed: type)
        if pointer.pointee == nil {
            pointer.initialize(to: T.initialize())
        }
        let raw = UnsafeMutableRawPointer(pointer)
        return raw.assumingMemoryBound(to: T.self)
    }
    
    func existingContainer<T>(typed type: T.Type) -> T? where T: Aggregatable {
        return self.mutablePointer(typed: type).pointee
    }
    
    func deinitialize<T>(typed type: T.Type) where T: Aggregatable {
        self.mutablePointer(typed: type).deinitialize(count: 1)
    }
}

// ----------------------------------
//  MARK: - Function -
//
private extension UnsafeMutableRawPointer {
    func function<T>(typed: T.Type) -> Function.Aggregate<T> where T: Aggregatable, T: AnyObject {
        return Unmanaged<Function.Aggregate<T>>.fromOpaque(self).takeUnretainedValue()
    }
}

private extension Function.Aggregate {
    var pointer: UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(self).toOpaque()
    }
}
