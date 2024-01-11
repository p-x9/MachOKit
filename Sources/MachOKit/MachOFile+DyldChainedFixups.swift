//
//  MachOFile+DyldChainedFixups.swift
//
//
//  Created by p-x9 on 2024/01/11.
//
//

import Foundation
import MachOKitC

extension MachOFile {
    public struct DyldChainedFixups {
        let data: Data
        let isSwapped: Bool
    }
}

extension MachOFile.DyldChainedFixups: DyldChainedFixupsProtocol {
    public var header: DyldChainedFixupsHeader? {
        data.withUnsafeBytes {
            guard let basePtr = $0.baseAddress else { return nil }
            let ptr = UnsafeRawPointer(basePtr)
            let ret = ptr
                .assumingMemoryBound(to: DyldChainedFixupsHeader.self)
                .pointee
            return isSwapped ? ret.swapped : ret
        }
    }

    public var startsInImage: DyldChainedStartsInImage? {
        guard let header else { return nil }
        return data.withUnsafeBytes {
            guard let basePtr = $0.baseAddress else { return nil }
            let offset: Int = numericCast(header.starts_offset)
            let ptr = UnsafeRawPointer(basePtr)
                .advanced(by: offset)
            let layout =  ptr
                .assumingMemoryBound(to: DyldChainedStartsInImage.Layout.self)
                .pointee
            let ret: DyldChainedStartsInImage = .init(
                layout: layout,
                offset: offset
            )
            return isSwapped ? ret.swapped : ret
        }
    }

    public func startsInSegments(
        of startsInImage: DyldChainedStartsInImage?
    ) -> [DyldChainedStartsInSegment] {
        guard let startsInImage else {
            return []
        }
        let offsets: [Int] = data.withUnsafeBytes {
            guard let basePtr = $0.baseAddress else { return [] }
            let ptr = UnsafeRawPointer(basePtr)
                .advanced(by: startsInImage.offset)
                .advanced(by: DyldChainedStartsInImage.layoutOffset(of: \.seg_info_offset))
            return UnsafeBufferPointer(
                start: ptr.assumingMemoryBound(to: UInt32.self),
                count: numericCast(startsInImage.seg_count)
            )
            .map { isSwapped ? $0.byteSwapped : $0 }
            .map { numericCast($0) }
        }

        return data.withUnsafeBytes {
            guard let basePtr = $0.baseAddress else { return [] }
            let ptr = UnsafeRawPointer(basePtr)
                .advanced(by: startsInImage.offset)
            return offsets.map {
                let layout = ptr.advanced(by: $0)
                    .assumingMemoryBound(to: DyldChainedStartsInSegment.Layout.self)
                    .pointee
                let offset: Int = startsInImage.offset + $0
                let ret: DyldChainedStartsInSegment = .init(
                    layout: layout,
                    offset: offset
                )
                return isSwapped ? ret.swapped : ret
            }
        }
    }

    public func pages(
        of startsInSegment: DyldChainedStartsInSegment?
    ) -> [DyldChainedPage] {
        guard let startsInSegment else {
            return []
        }

        return data.withUnsafeBytes {
            guard let basePtr = $0.baseAddress else { return [] }
            let ptr = UnsafeRawPointer(basePtr)
                .advanced(by: startsInSegment.offset)
                .advanced(by: startsInSegment.layoutOffset(of: \.page_start))
                .assumingMemoryBound(to: UInt16.self)
            return UnsafeBufferPointer(
                start: ptr,
                count: numericCast(
                    startsInSegment.page_count
                )
            )
            .map {
                isSwapped ? $0.byteSwapped : $0
            }
            .map { .init(offset: $0) }
        }
    }

    public var imports: [DyldChainedImport] {
        guard let header,
              let  importsFormat = header.importsFormat else {
            return []
        }
        return data.withUnsafeBytes {
            guard let basePtr = $0.baseAddress else { return [] }
            let offset: Int = numericCast(header.imports_offset)
            let ptr = UnsafeRawPointer(basePtr)
                .advanced(by: offset)
            let count: Int = numericCast(header.imports_count)

            switch importsFormat {
            case .general:
                return UnsafeBufferPointer(
                    start: ptr
                        .assumingMemoryBound(to: DyldChainedImportGeneral.self),
                    count: count
                )
                .map { isSwapped ? $0.swapped : $0 }
                .map { .general($0) }

            case .addend:
                return UnsafeBufferPointer(
                    start: ptr
                        .assumingMemoryBound(to: DyldChainedImportAddend.self),
                    count: count
                )
                .map { isSwapped ? $0.swapped : $0 }
                .map { .addend($0) }

            case .addend64:
                return UnsafeBufferPointer(
                    start: ptr
                        .assumingMemoryBound(to: DyldChainedImportAddend64.self),
                    count: count
                )
                .map { isSwapped ? $0.swapped : $0 }
                .map { .addend64($0) }
            }
        }
    }

    public func symbolName(for nameOffset: Int) -> String? {
        guard let header else {
            return nil
        }
        return data.withUnsafeBytes {
            guard let basePtr = $0.baseAddress else { return nil }
            let ptr = basePtr
                .advanced(by: numericCast(header.symbols_offset))
                .advanced(by: nameOffset)
                .assumingMemoryBound(to: CChar.self)
            return String(cString: ptr)
        }
    }
}
