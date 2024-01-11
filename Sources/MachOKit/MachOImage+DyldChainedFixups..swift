//
//  MachOImage+DyldChainedFixups..swift
//
//
//  Created by p-x9 on 2024/01/11.
//  
//

import Foundation

extension MachOImage {
    public struct DyldChainedFixups {
        public let basePointer: UnsafePointer<UInt8>
        public let dyldChainedFixupsSize: Int
    }
}

extension MachOImage.DyldChainedFixups {
    init?(
        dyldChainedFixups: linkedit_data_command,
        linkedit: SegmentCommand64,
        text: SegmentCommand64,
        vmaddrSlide: Int
    ) {
        var linkeditStart = vmaddrSlide
        linkeditStart += numericCast(linkedit.layout.vmaddr - linkedit.layout.fileoff)
        guard let linkeditStartPtr = UnsafeRawPointer(bitPattern: linkeditStart) else {
            return nil
        }

        let start = linkeditStartPtr
            .advanced(by: numericCast(dyldChainedFixups.dataoff))
            .assumingMemoryBound(to: UInt8.self)
        let size: Int = numericCast(dyldChainedFixups.datasize)

        self.init(
            basePointer: start,
            dyldChainedFixupsSize: size
        )
    }

    init?(
        dyldChainedFixups: linkedit_data_command,
        linkedit: SegmentCommand,
        text: SegmentCommand,
        vmaddrSlide: Int
    ) {
        var linkeditStart = vmaddrSlide
        linkeditStart += numericCast(linkedit.layout.vmaddr - linkedit.layout.fileoff)
        guard let linkeditStartPtr = UnsafeRawPointer(bitPattern: linkeditStart) else {
            return nil
        }

        let start = linkeditStartPtr
            .advanced(by: numericCast(dyldChainedFixups.dataoff))
            .assumingMemoryBound(to: UInt8.self)
        let size: Int = numericCast(dyldChainedFixups.datasize)

        self.init(
            basePointer: start,
            dyldChainedFixupsSize: size
        )
    }
}

extension MachOImage.DyldChainedFixups: DyldChainedFixupsProtocol {
    public var header: DyldChainedFixupsHeader? {
        let ptr = UnsafeRawPointer(basePointer)
        return ptr
            .assumingMemoryBound(to: DyldChainedFixupsHeader.self)
            .pointee
    }

    public var startsInImage: DyldChainedStartsInImage? {
        guard let header else { return nil }
        let offset: Int = numericCast(header.starts_offset)
        let ptr = UnsafeRawPointer(basePointer)
            .advanced(by: offset)
        let layout = ptr
            .assumingMemoryBound(to: DyldChainedStartsInImage.Layout.self)
            .pointee
        return .init(layout: layout, offset: offset)
    }

    public func startsInSegments(
        of startsInImage: DyldChainedStartsInImage?
    ) -> [DyldChainedStartsInSegment] {
        guard let startsInImage else {
            return []
        }
        let offsets: [Int] = {
            let ptr = UnsafeRawPointer(basePointer)
                .advanced(by: startsInImage.offset)
                .advanced(by: DyldChainedStartsInImage.layoutOffset(of: \.seg_info_offset))
            return UnsafeBufferPointer(
                start: ptr.assumingMemoryBound(to: UInt32.self),
                count: numericCast(startsInImage.seg_count)
            ).map { numericCast($0) }
        }()

        let ptr = UnsafeRawPointer(basePointer)
            .advanced(by: startsInImage.offset)
        return offsets.map {
            let layout = ptr.advanced(by: $0)
                .assumingMemoryBound(to: DyldChainedStartsInSegment.Layout.self)
                .pointee
            let offset: Int = startsInImage.offset + $0
            return .init(layout: layout, offset: offset)
        }
    }

    public func pages(
        of startsInSegment: DyldChainedStartsInSegment?
    ) -> [DyldChainedPage] {
        guard let startsInSegment else {
            return []
        }

        let ptr = UnsafeRawPointer(basePointer)
            .advanced(by: startsInSegment.offset)
            .advanced(by: startsInSegment.layoutOffset(of: \.page_start))
            .assumingMemoryBound(to: UInt16.self)
        return UnsafeBufferPointer(
            start: ptr,
            count: numericCast(
                startsInSegment.page_count
            )
        ).map { .init(offset: $0) }
    }

    public var imports: [DyldChainedImport] {
        guard let header,
              let  importsFormat = header.importsFormat else {
            return []
        }

        let offset: Int = numericCast(header.imports_offset)
        let ptr = UnsafeRawPointer(basePointer)
            .advanced(by: offset)
        let count: Int = numericCast(header.imports_count)

        switch importsFormat {
        case .general:
            return UnsafeBufferPointer(
                start: ptr
                    .assumingMemoryBound(to: DyldChainedImportGeneral.self),
                count: count
            ).map { .general($0) }

        case .addend:
            return UnsafeBufferPointer(
                start: ptr
                    .assumingMemoryBound(to: DyldChainedImportAddend.self),
                count: count
            ).map { .addend($0) }

        case .addend64:
            return UnsafeBufferPointer(
                start: ptr
                    .assumingMemoryBound(to: DyldChainedImportAddend64.self),
                count: count
            ).map { .addend64($0) }
        }
    }

    public func symbolName(for nameOffset: Int) -> String? {
        guard let header else {
            return nil
        }
        let ptr = UnsafeRawPointer(basePointer)
            .advanced(by: numericCast(header.symbols_offset))
            .advanced(by: nameOffset)
            .assumingMemoryBound(to: CChar.self)
        return String(cString: ptr)
    }
}
