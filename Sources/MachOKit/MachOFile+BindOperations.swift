//
//  MachOFile+BindOperations.swift
//
//
//  Created by p-x9 on 2023/12/09.
//  
//

import Foundation

extension MachOFile {
    public struct BindOperations: Sequence {
        public let data: Data
        public let bindOffset: Int
        public let bindSize: Int

        public func makeIterator() -> Iterator {
            .init(data: data)
        }
    }
}

extension MachOFile.BindOperations {
    init(
        machO: MachOFile,
        info: dyld_info_command,
        kind: BindOperationsKind = .normal
    ) {
        let bindOffset = Int(kind.bindOffset(of: info))
        let bindSize = Int(kind.bindSize(of: info))
        let offset = machO.headerStartOffset + bindOffset
        machO.fileHandle.seek(
            toFileOffset: UInt64(offset)
        )
        let data = machO.fileHandle.readData(ofLength: bindSize)
        self.init(data: data, bindOffset: bindOffset, bindSize: bindSize)
    }
}

extension MachOFile.BindOperations {
    public struct Iterator: IteratorProtocol {
        public typealias Element = BindOperation

        private let data: Data
        private var nextOffset: Int = 0

        init(data: Data) {
            self.data = data
        }

        public mutating func next() -> Element? {
            guard nextOffset < data.count else { return nil }

            return data.withUnsafeBytes {
                guard let basePointer = $0.baseAddress else { return nil }

                return BindOperation.readNext(
                    basePointer: basePointer.assumingMemoryBound(to: UInt8.self),
                    bindSize: data.count,
                    nextOffset: &nextOffset
                )
            }
        }
    }
}
