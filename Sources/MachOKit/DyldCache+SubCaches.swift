//
//  DyldCache+Subcaches.swift
//
//
//  Created by p-x9 on 2024/01/15.
//  
//

import Foundation

extension DyldCache {
    public struct SubCaches: Sequence {
        public let data: Data // DyldSubCacheEntryGeneral * numberOfSubCaches
        public let numberOfSubCaches: Int
        public let subCacheEntryType: DyldSubCacheEntryType

        public func makeIterator() -> Iterator {
            .init(
                data: data,
                numberOfSubCaches: numberOfSubCaches,
                subCacheEntryType: subCacheEntryType
            )
        }
    }
}

extension DyldCache.SubCaches {
    public struct Iterator: IteratorProtocol {
        public typealias Element = DyldSubCacheEntry

        public let data: Data // DyldSubCacheEntryGeneral * numberOfSubCaches
        public let numberOfSubCaches: Int
        public let subCacheEntryType: DyldSubCacheEntryType

        private var nextOffset: Int = 0
        private var nextIndex: Int = 0

        public init(
            data: Data,
            numberOfSubCaches: Int,
            subCacheEntryType: DyldSubCacheEntryType
        ) {
            self.data = data
            self.numberOfSubCaches = numberOfSubCaches
            self.subCacheEntryType = subCacheEntryType
        }

        public mutating func next() -> DyldSubCacheEntry? {
            guard nextOffset < data.count else {
                return nil
            }
            guard nextIndex < numberOfSubCaches else {
                return nil
            }

            defer {
                nextIndex += 1
                nextOffset += subCacheEntryType.layoutSize
            }

            switch subCacheEntryType {
            case .general:
                return data.withUnsafeBytes {
                    guard let baseAddress = $0.baseAddress else { return nil }

                    let ptr = UnsafeMutableRawPointer(mutating: baseAddress)
                        .advanced(by: nextOffset)
                        .assumingMemoryBound(to: DyldSubCacheEntryGeneral.Layout.self)
                    return .general(.init(layout: ptr.pointee, index: nextIndex))
                }
            case .v1:
                return data.withUnsafeBytes {
                    guard let baseAddress = $0.baseAddress else { return nil }

                    let ptr = UnsafeMutableRawPointer(mutating: baseAddress)
                        .advanced(by: nextOffset)
                        .assumingMemoryBound(to: DyldSubCacheEntryV1.Layout.self)
                    return .v1(.init(layout: ptr.pointee, index: nextIndex))
                }
            }
        }
    }
}
