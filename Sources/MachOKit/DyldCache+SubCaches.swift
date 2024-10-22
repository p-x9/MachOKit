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

                    let ptr = baseAddress
                        .advanced(by: nextOffset)
                        .assumingMemoryBound(to: DyldSubCacheEntryGeneral.Layout.self)
                    return .general(.init(layout: ptr.pointee, index: nextIndex))
                }
            case .v1:
                return data.withUnsafeBytes {
                    guard let baseAddress = $0.baseAddress else { return nil }

                    let ptr = baseAddress
                        .advanced(by: nextOffset)
                        .assumingMemoryBound(to: DyldSubCacheEntryV1.Layout.self)
                    return .v1(.init(layout: ptr.pointee, index: nextIndex))
                }
            }
        }
    }
}

extension DyldCache.SubCaches: Collection {
    public typealias Index = Int

    public var startIndex: Index { 0 }
    public var endIndex: Index { numberOfSubCaches }

    public func index(after i: Int) -> Int {
        i + 1
    }

    public subscript(position: Int) -> Element {
        precondition(position >= 0)
        precondition(position < endIndex)
        precondition(data.count >= (position + 1) * subCacheEntryType.layoutSize)
        switch subCacheEntryType {
        case .general:
            return data.withUnsafeBytes {
                guard let baseAddress = $0.baseAddress else { fatalError("data is empty") }

                let ptr = baseAddress
                    .advanced(by: position * subCacheEntryType.layoutSize)
                    .assumingMemoryBound(to: DyldSubCacheEntryGeneral.Layout.self)
                return .general(.init(layout: ptr.pointee, index: position))
            }
        case .v1:
            return data.withUnsafeBytes {
                guard let baseAddress = $0.baseAddress else { fatalError("data is empty") }

                let ptr = baseAddress
                    .advanced(by: position * subCacheEntryType.layoutSize)
                    .assumingMemoryBound(to: DyldSubCacheEntryV1.Layout.self)
                return .v1(.init(layout: ptr.pointee, index: position))
            }
        }
    }
}

extension DyldCache.SubCaches: RandomAccessCollection {}
