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
        let machO: MachOFile
        public let bindOffset: Int
        public let bindSize: Int

        public func makeIterator() -> Iterator {
            let offset = machO.headerStartOffset + bindOffset
            machO.fileHandle.seek(
                toFileOffset: UInt64(offset)
            )
            let data = machO.fileHandle.readData(ofLength: bindSize)

            return .init(data: data)
        }
    }
}

extension MachOFile.BindOperations {
    init(
        machO: MachOFile,
        info: dyld_info_command,
        kind: BindOperationsKind = .normal
    ) {
        self.init(
            machO: machO,
            bindOffset: Int(kind.bindOffset(of: info)),
            bindSize: Int(kind.bindSize(of: info))
        )
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
