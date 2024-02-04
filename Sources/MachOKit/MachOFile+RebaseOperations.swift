//
//  MachOFile+RebaseOperations.swift
//  
//
//  Created by p-x9 on 2023/12/09.
//  
//

import Foundation

extension MachOFile {
    public struct RebaseOperations: Sequence {
        public let data: Data
        public let rebaseOffset: Int
        public let rebaseSize: Int

        public func makeIterator() -> Iterator {
            .init(data: data)
        }
    }
}

extension MachOFile.RebaseOperations {
    init(
        machO: MachOFile,
        rebaseOffset: Int,
        rebaseSize: Int
    ) {
        let offset = machO.headerStartOffset + rebaseOffset
        let data = machO.fileHandle.readData(
            offset: numericCast(offset),
            size: rebaseSize
        )

        self.init(
            data: data,
            rebaseOffset: rebaseOffset,
            rebaseSize: rebaseSize
        )
    }

    init(
        machO: MachOFile,
        info: dyld_info_command
    ) {
        self.init(
            machO: machO,
            rebaseOffset: Int(info.rebase_off),
            rebaseSize: Int(info.rebase_size)
        )
    }
}

extension MachOFile.RebaseOperations {
    public struct Iterator: IteratorProtocol {
        public typealias Element = RebaseOperation

        private let data: Data
        private var nextOffset: Int = 0
        private var done = false

        init(data: Data) {
            self.data = data
        }

        public mutating func next() -> Element? {
            guard !done, nextOffset < data.count else { return nil }

            return data.withUnsafeBytes {
                guard let basePointer = $0.baseAddress else { return nil }

                return RebaseOperation.readNext(
                    basePointer: basePointer.assumingMemoryBound(to: UInt8.self),
                    rebaseSize: data.count,
                    nextOffset: &nextOffset,
                    done: &done
                )
            }
        }
    }
}
