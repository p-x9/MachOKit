//
//  CFStringCollection.swift
//  MachOKit
//

import Foundation

/// A raw-backed collection that attaches each constant string's unslid VM address.
public struct CFStringCollection<Value: LayoutWrapper & CFStringProtocol>: RandomAccessCollection {
    private enum Storage {
        case data(DataSequence<Value.Layout>)
        case memory(MemorySequence<Value.Layout>)
    }

    private let storage: Storage
    private let makeValue: (Value.Layout, UInt64) -> Value

    /// The unslid virtual memory address of the first record.
    public let address: UInt64

    public var startIndex: Int { 0 }
    public var endIndex: Int {
        switch storage {
        case .data(let records): records.endIndex
        case .memory(let records): records.endIndex
        }
    }

    init(
        data: Data,
        address: UInt64,
        makeValue: @escaping (Value.Layout, UInt64) -> Value
    ) {
        storage = .data(.init(data: data, numberOfElements: data.count / Value.layoutSize))
        self.address = address
        self.makeValue = makeValue
    }

    init(
        basePointer: UnsafePointer<Value.Layout>,
        count: Int,
        address: UInt64,
        makeValue: @escaping (Value.Layout, UInt64) -> Value
    ) {
        storage = .memory(.init(basePointer: basePointer, numberOfElements: count))
        self.address = address
        self.makeValue = makeValue
    }

    public subscript(position: Int) -> Value {
        precondition(indices.contains(position), "CFString index out of range")
        let layout: Value.Layout
        switch storage {
        case .data(let records): layout = records[position]
        case .memory(let records): layout = records[position]
        }
        return makeValue(layout, address + UInt64(position * Value.layoutSize))
    }
}
