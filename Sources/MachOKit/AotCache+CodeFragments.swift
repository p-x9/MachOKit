//
//  AotCache+CodeFragments.swift
//  MachOKit
//
//  Created by p-x9 on 2025/12/15
//  
//

import Foundation
import MachOKitC
#if compiler(>=6.0) || (compiler(>=5.10) && hasFeature(AccessLevelOnImport))
internal import FileIO
#else
@_implementationOnly import FileIO
#endif

extension AotCache {
    public struct CodeFragments: Sequence {
        typealias FileSlice = File.FileSlice

        private let fileSlice: FileSlice

        public let offset: Int
        public let size: Int

        public let numberOfEntries: Int

        init(
            fileSlice: FileSlice,
            offset: Int,
            size: Int,
            numberOfEntries: Int
        ) {
            self.fileSlice = fileSlice
            self.offset = offset
            self.size = size
            self.numberOfEntries = numberOfEntries
        }

        public func makeIterator() -> Iterator {
            .init(
                fileSlice: fileSlice,
                numberOfEntries: numberOfEntries
            )
        }
    }
}

extension AotCache.CodeFragments {
    public var data: Data? {
        try? fileSlice.readAllData()
    }
}

extension AotCache.CodeFragments {
    public struct Iterator: IteratorProtocol {
        public typealias Element = AotCodeFragment

        private let fileSlice: FileSlice
        private let numberOfEntries: Int

        private var nextOffset: Int = 0
        private var nextIndex: Int = 0

        init(fileSlice: FileSlice, numberOfEntries: Int) {
            self.fileSlice = fileSlice
            self.numberOfEntries = numberOfEntries
        }

        public mutating func next() -> Element? {
            guard nextOffset < fileSlice.size else { return nil }
            guard nextIndex < numberOfEntries else { return nil }

            let layout: Element.Layout? = try? fileSlice.read(
                offset: nextOffset
            )
            guard let layout else { return nil }

            guard AotCodeFragmentType(rawValue: layout.type) != nil else {
                return nil
            }

            defer {
                nextOffset += Element.layoutSize
                nextOffset += numericCast(layout.branch_map_size)
                nextOffset += numericCast(layout.instruction_map_size)

                nextIndex += 1
            }

            return .init(layout: layout)
        }
    }
}
