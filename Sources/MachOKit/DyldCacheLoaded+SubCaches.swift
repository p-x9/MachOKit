//
//  DyldCacheLoaded+SubCaches.swift
//
//
//  Created by p-x9 on 2024/10/10
//  
//

import Foundation

extension DyldCacheLoaded {
    public struct SubCaches: Sequence {
        public let basePointer: UnsafeRawPointer
        public let numberOfSubCaches: Int
        public let subCacheEntryType: DyldSubCacheEntryType

        public func makeIterator() -> Iterator {
            .init(
                basePointer: basePointer,
                numberOfSubCaches: numberOfSubCaches,
                subCacheEntryType: subCacheEntryType
            )
        }
    }
}

extension DyldCacheLoaded.SubCaches {
    public struct Iterator: IteratorProtocol {
        public typealias Element = DyldSubCacheEntry

        public let basePointer: UnsafeRawPointer
        public let numberOfSubCaches: Int
        public let subCacheEntryType: DyldSubCacheEntryType

        private var nextOffset: Int = 0
        private var nextIndex: Int = 0

        public init(
            basePointer: UnsafeRawPointer,
            numberOfSubCaches: Int,
            subCacheEntryType: DyldSubCacheEntryType
        ) {
            self.basePointer = basePointer
            self.numberOfSubCaches = numberOfSubCaches
            self.subCacheEntryType = subCacheEntryType
        }

        public mutating func next() -> DyldSubCacheEntry? {
            guard nextIndex < numberOfSubCaches else {
                return nil
            }

            defer {
                nextIndex += 1
                nextOffset += subCacheEntryType.layoutSize
            }

            switch subCacheEntryType {
            case .general:
                let ptr = UnsafeMutableRawPointer(mutating: basePointer)
                    .advanced(by: nextOffset)
                    .assumingMemoryBound(to: DyldSubCacheEntryGeneral.Layout.self)
                return .general(.init(layout: ptr.pointee, index: nextIndex))
            case .v1:
                let ptr = UnsafeMutableRawPointer(mutating: basePointer)
                    .advanced(by: nextOffset)
                    .assumingMemoryBound(to: DyldSubCacheEntryV1.Layout.self)
                return .v1(.init(layout: ptr.pointee, index: nextIndex))
            }
        }
    }
}
